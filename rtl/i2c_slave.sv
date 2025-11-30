module i2c_slave( 
  inout SDA,
  input SCL, rst_n,
  input [6:0] address,  //chip_id
  
  output reg[7:0] reg_addr,
  output reg wr1rd0,
  output reg[7:0] reg_wr_data,
  input reg[7:0] reg_rd_data,
  output reg reg_req
);

  reg [2:0] count;
  reg sda; 
  reg [7:0] chip_addr;
  reg ACK;

  enum reg[3:0] {
    IDLE, 
    SAMPLE_BYTE_1, ACK1, 
    SAMPLE_BYTE_2, ACK2, 
    SAMPLE_BYTE_3, ACK3,
    SEND_BYTE_3, ACK3_GET
  } state;

  // 1. Detectores Asíncronos
  logic start_detected;
  logic stop_detected;

  always @(negedge SDA or negedge SCL) begin
    if (SCL == 0) start_detected = 0;
    else          start_detected = 1;
  end

  always @(posedge SDA or negedge SCL) begin
    if (SCL == 0) stop_detected = 0;
    else          stop_detected = 1;
  end
  
  always_ff @(SCL, negedge rst_n, posedge start_detected) begin

    if(!rst_n) begin
      count <= 7;
      sda <= 1;
      chip_addr <= 0;
      ACK <= 0;

      state <= IDLE;

      reg_addr <= 0;
      wr1rd0 <= 0;
      reg_wr_data <= 0;
      reg_req <= 0;

    end else if (start_detected) begin 
      count <= 7;
      sda <= 1;
      chip_addr <= 0;
      ACK <= 0;

      state <= SAMPLE_BYTE_1;

      reg_addr <= 0;
      wr1rd0 <= 0;
      reg_wr_data <= 0;
      reg_req <= 0;

    end else if (SCL == 1) begin // FSM que funciona con flancos positivos
      case (state)
        IDLE: begin
          count <= 7;
          sda <= 1;
          chip_addr <= 0;
          ACK <= 0;

          reg_addr <= 0;
          wr1rd0 <= 0;
          reg_wr_data <= 0;
          reg_req <= 0;
        end

        SAMPLE_BYTE_1: begin
          chip_addr[count] <= SDA;
          if(count == 0) begin
            if(chip_addr[7:1] == address) begin
                count <= 7;
                ACK <= 1; //ACK

                state <= ACK1;

                wr1rd0 <= SDA; // Guardamos si es Read o Write
            end else begin
                state <= IDLE; // No somos nosotros
            end
          end else begin
            count <= count - 1;
          end
        end

        ACK1: begin
          ACK <= 0; // NOT ACK

          state <= SAMPLE_BYTE_2;
        end

        SAMPLE_BYTE_2: begin
          reg_addr[count] <= SDA;
          if(count == 0) begin
            count <= 7;
            ACK <= 1;  // ACK

            state <= ACK2; 

            if(wr1rd0 == 0) reg_req <= 1;
          end else begin
            count <= count - 1;
          end
        end

        ACK2: begin
          ACK <= 0; //NOT ACK

          if(wr1rd0 == 0) begin 
            state <= SEND_BYTE_3;

            reg_req <= 0;
          end else begin   
            state <= SAMPLE_BYTE_3;
          end
        end

        SAMPLE_BYTE_3: begin
          reg_wr_data[count] <= SDA;
          if(count == 0) begin
            count <= 7;
            ACK <= 1; //ACK

            state <= ACK3;
            
            reg_req <= 1;
          end else begin
            count <= count - 1;
          end
        end

        SEND_BYTE_3: begin
          if(count == 0) begin // Overflow (0->7) indica fin de byte
              count <= 7;

              state <= ACK3_GET;
          end else begin
              count <= count - 1;
          end
        end

        ACK3: begin
          ACK <= 0;  // NOT ACK

          reg_req <= 0;

          state <= IDLE; 
        end

        ACK3_GET: begin
          ACK <= !SDA; // GET ACK

          state <= IDLE;
        end

      endcase

    end else if (SCL == 0) begin // FSM que funciona con flancos negativos
      case (state)
        IDLE: begin
          sda <= 1;
        end

        ACK1, ACK2, ACK3: begin
          sda <= 0;
        end

        SAMPLE_BYTE_2, SAMPLE_BYTE_3: begin
          sda <= 1;
        end

        SEND_BYTE_3: begin
          sda <= reg_rd_data[count];
        end    
      endcase
    end
  end
        
  assign SDA = (sda == 1) ? 1'bz : 1'b0;
  
endmodule
