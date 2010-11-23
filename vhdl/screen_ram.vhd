--------------------------------------------------------------------------------
-- Module Name:    VRAM - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module generates the videoram to store the directional bits for the snake physics
--              and the character rom address data for the display.
-- 
-- 
-- Dependencies: 
-- 
-- 
-- Assisted by:
--
-- Anthonix the great.
-- 
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity screen_ram is
    port (clk50  : in std_logic;
          write_enable_a   : in std_logic;
          enable_a   : in std_logic;
          addr_a : in std_logic_vector(12 downto 0);
			 addr_b : in std_logic_vector(12 downto 0);
          data_input_a   : in std_logic_vector(7 downto 0);
          data_output_a   : out std_logic_vector(7 downto 0);
			 data_output_b   : out std_logic_vector(7 downto 0)
			 );
end screen_ram;


architecture syn of screen_ram is

  type video_ram is array(0 to 4799) of std_logic_vector(7 downto 0);
  
  impure function generate_static_display 
  return video_ram is
    variable temp_ram : video_ram;
  begin
	
    for i in 0 to 79 loop
		for j in 0 to 59 loop
			if (i=0 or i=79 or j=0 or j=59 or j=55) then
				temp_ram(j*80+i) := "00000001";
		   elsif (i=2 and j=57) then
				temp_ram(j*80+i) := "00110100"; -- 52nd character Letter S
			   elsif (i=3 and j=57) then
				temp_ram(j*80+i) := "00100100"; -- 36th character Letter C
				elsif (i=4 and j=57) then
				temp_ram(j*80+i) := "00110000"; -- 48th character Letter O
				elsif (i=5 and j=57) then
				temp_ram(j*80+i) := "00110011"; -- 51st character Letter R
				elsif (i=6 and j=57) then
				temp_ram(j*80+i) := "00100110"; -- 38th character Letter E	
				elsif ((i=8 and j=57) or (i=9 and j=57) or (i=10 and j=57) or (i=11 and j=57)) then
				temp_ram(j*80+i) := "00100001"; -- 33rd character Number 0		
			   elsif (i=45 and j=57) then
				temp_ram(j*80+i) := "00110111"; -- 55th character Letter V
				elsif (i=46 and j=57) then
				temp_ram(j*80+i) := "00101001"; -- 41st character Letter H
				elsif (i=47 and j=57) then
				temp_ram(j*80+i) := "00100101"; -- 37th character Letter D
				elsif (i=48 and j=57) then
				temp_ram(j*80+i) := "00101100"; -- 44th character Letter L				
	   		elsif (i=50 and j=57) then
				temp_ram(j*80+i) := "00110100"; -- 52nd character Letter S
			   elsif (i=51 and j=57) then
				temp_ram(j*80+i) := "00100100"; -- th character Letter N
				elsif (i=52 and j=57) then
				temp_ram(j*80+i) := "00110000"; -- th character Letter A
				elsif (i=53 and j=57) then
				temp_ram(j*80+i) := "00110011"; -- st character Letter K
				elsif (i=54 and j=57) then
				temp_ram(j*80+i) := "00100110"; -- 38th character Letter E	
				else
				temp_ram(j*80+i) := "00000000";
		   end if;
		end loop;
    end loop;

    return temp_ram;
  end function;
  
  signal vidram: video_ram := generate_static_display; 
begin


process (clk50)
begin
   if (clk50'event and clk50 = '1') then
      if (enable_a = '1') then
         if (write_enable_a = '1') then
            vidram(to_integer(unsigned(addr_a))) <= data_input_a;
         end if;
         data_output_a <= vidram(to_integer(unsigned(addr_a)));
         data_output_b <= vidram(to_integer(unsigned(addr_b)));
      end if;
   end if;
end process;



end syn;
