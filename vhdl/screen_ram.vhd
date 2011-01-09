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
  port (clk25          : in  std_logic;
        write_enable_a : in  std_logic;
        enable_a       : in  std_logic;
        addr_a         : in  std_logic_vector(12 downto 0);
        addr_b         : in  std_logic_vector(12 downto 0);
        data_input_a   : in  unsigned(11 downto 0);
        data_output_a  : out unsigned(11 downto 0);
        data_output_b  : out unsigned(11 downto 0)
        );
end screen_ram;


architecture syn of screen_ram is

  type video_ram is array(0 to 8191) of unsigned(11 downto 0);

  impure function generate_static_display
    return video_ram is
    variable temp_ram : video_ram;
  begin
    
    for i in 0 to 79 loop
      for j in 0 to 59 loop
        if (i = 0 or i = 79 or j = 0 or j = 59 or j = 55) then
          temp_ram(j*80+i) := to_unsigned(8, 12);     -- BORDERS
        elsif (i = 2 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(52*8, 12);  -- S
        elsif (i = 3 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(36*8, 12);  -- C
        elsif (i = 4 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(48*8, 12);  -- O
        elsif (i = 5 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(51*8, 12);  -- R
        elsif (i = 6 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(38*8, 12);  -- E       
        elsif ((i = 8 and j = 57) or (i = 9 and j = 57) or (i = 10 and j = 57) or (i = 11 and j = 57)) then
          temp_ram(j*80+i) := to_unsigned(24*8, 12);  -- 0               
        elsif (i = 66 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(55*8, 12);  -- V
        elsif (i = 67 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(41*8, 12);  -- H
        elsif (i = 68 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(37*8, 12);  -- D
        elsif (i = 69 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(45*8, 12);  -- L                               
        elsif (i = 71 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(52*8, 12);  -- S
        elsif (i = 72 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(47*8, 12);  -- N
        elsif (i = 73 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(34*8, 12);  -- A
        elsif (i = 74 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(44*8, 12);  -- K
        elsif (i = 75 and j = 57) then
          temp_ram(j*80+i) := to_unsigned(38*8, 12);  -- E       
		        elsif (i = 40 and j = 30) then
          temp_ram(j*80+i) := "001000011000";  -- Snake Head  
		        elsif (i = 40 and j = 31) then
          temp_ram(j*80+i) := "001000011000";  -- Snake Tail 					 
        else
          temp_ram(j*80+i) := (others => '0');
        end if;
      end loop;
    end loop;

    return temp_ram;
  end function;

  signal vidram : video_ram := generate_static_display;
  
  

  
begin


  process (clk25)
  begin
    if (clk25'event and clk25 = '1') then
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
