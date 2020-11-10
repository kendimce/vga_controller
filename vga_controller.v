`timescale 1ns/1ns

module vga_controller(clk,rst,VSYNC,HSYNC,R,G,B);

	input clk,rst;
	output reg VSYNC,HSYNC;  //Sync pulses
	output reg [3:0] R;
	output reg [3:0] G;
	output reg [3:0] B;				//RGB Color
	
	integer clock_counter=0;
	reg divided_clk;
	
	
	parameter HSYNC_PULSE  =96;
	parameter HBACK_PORCH  =48;
	parameter HFRONT_PORCH =16;
	parameter H_WHOLE 	  =800;
	parameter H_VISIBLE    =640;
	reg [9:0] H_Counter;
	
	parameter VSYNC_PULSE  =2;
	parameter VBACK_PORCH  =33;
	parameter VFRONT_PORCH =10;
	parameter V_WHOLE 	  =525;
	parameter V_VISIBLE 	  =480;
	reg [9:0] V_Counter;
	
	
	reg [3:0] RGB_Counter;
	reg visible_enable;
	reg V_CHECK;
	
	initial
	begin

	divided_clk<=0;	
	
	VSYNC<=1;
	HSYNC<=1;
	H_Counter<=1;
	V_Counter<=1;
	
	RGB_Counter<=0;
	V_CHECK<=0;
	visible_enable<=1;
	end


	//CLOCK DIVIDER
	always @(posedge clk)
	begin
	
			if(clock_counter==1)				//25Mhz Clock for VGA
			begin
					divided_clk<= ~divided_clk;
					clock_counter<=0;
					
			
			end
			
			else
			begin
					clock_counter<=clock_counter+1'b1;
			
			end
			
	
	end
	
	
	always @(posedge divided_clk)
	begin
	
	if(V_CHECK==0)
	begin	
				
				
				H_Counter<= H_Counter+1;
				RGB_Counter<=RGB_Counter+1;

				if(H_Counter<H_VISIBLE+1)
				begin


									//COMMON VISIBLE AREA BOTH V AND H ACTIVE
						if(visible_enable==1)
						begin
								R[3:0]<=RGB_Counter[3:0];
								G[3:0]<=RGB_Counter[3:0];
								B[3:0]<=RGB_Counter[3:0];
									
						end
						else
						begin
								R[3:0]<=0;
								G[3:0]<=0;
								B[3:0]<=0;


						end
				end

				if(H_Counter> H_VISIBLE && H_Counter<= H_VISIBLE+HFRONT_PORCH)
				begin
						R[3:0]<=4'hzzzz;
						G[3:0]<=4'hzzzz;
						B[3:0]<=4'hzzzz;
				


				end

				if(H_Counter> H_VISIBLE+HFRONT_PORCH && H_Counter<=H_VISIBLE + HFRONT_PORCH + HSYNC_PULSE)
				HSYNC<=0;

				if(H_Counter > H_VISIBLE + HFRONT_PORCH + HSYNC_PULSE && H_Counter <= H_WHOLE)
				begin

				HSYNC<=1;
				R[3:0]<=4'hzzzz;
				G[3:0]<=4'hzzzz;
				B[3:0]<=4'hzzzz;
				
						if(H_Counter== H_WHOLE)
						begin
							H_Counter<=0;
							V_Counter<=V_Counter+1;
							V_CHECK<=1;	
							
						end

				end
		end

	if(V_CHECK==1)
	begin
			if(V_Counter <= V_VISIBLE )
				visible_enable<=1;
			
			if(V_Counter > V_VISIBLE)
				visible_enable<=0;
			
			if(V_Counter > V_VISIBLE+ VFRONT_PORCH && V_Counter <= V_VISIBLE + VFRONT_PORCH + VSYNC_PULSE)
				VSYNC<=0;

			if(V_Counter > V_VISIBLE + VFRONT_PORCH + VSYNC_PULSE)
				VSYNC<=1;
			
			if(V_Counter == V_WHOLE)
				V_Counter<=0;

			V_CHECK<=0;

	end


end


	endmodule
