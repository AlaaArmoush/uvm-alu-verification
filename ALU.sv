module alu (
    input logic signed [31:0] A,  // operand 1
    input logic [31:0] B,  // operand 2
    input logic [2:0] Opcode,     // opcode
    output logic [31:0] Result,   // result
    output logic Error            // error flag for overflow
);

    // Opcode encoding
    // 3'b000: Addition
    // 3'b001: Subtraction
    // 3'b010: AND
    // 3'b011: OR
    // 3'b100: XOR
    // 3'b101: Reserved
    // 3'b110: Reserved
    // 3'b111: Reserved


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            Result <= 32'b0;
            Error <= 1'b0;
        end
        else begin
            
            case (Opcode)
                3'b000: begin
                    // Addition operation
                    Result = A + B;

                    // Detect overflow in signed addition
                if ((A < 0 && B > 0 && Result > A) || (A > 0 && B < 0 && Result < A)) 
                    Error = 1;
                end

                3'b001: begin
                    // Subtraction operation (A - B)
                    Result = A - B;

                    // Detect overflow in signed subtraction
                if ((A < 0 && B > 0 && Result > A) || (A > 0 && B < 0 && Result < A)) 
                    Error = 1;
                end

                3'b010: begin
                    // AND operation
                    Result = A & B;
                end

                3'b011: begin
                    // OR operation
                    Result = A | B;
                end

                3'b100: begin
                    // XOR operation
                    Result = A ^ B;
                end

                default: begin
                    Result = 32'b0;  // Default to 0 for unsupported opcodes
                    Error = 1'b1;         // Set error flag for invalid opcode
                end
            endcase

        end
    end

endmodule
