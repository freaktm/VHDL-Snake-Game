--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
--              
-- 
-- 
-- Dependencies: VRAM
-- 
-- 
-- Assisted by:
--
-- Anthonix the great.
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_logic is
  port( 
		 clk25 : in std_logic;
       ext_reset   : in  std_logic;
       WEA_int     : out std_logic;
       EN_int      : out std_logic;
       address_a_int : out unsigned(12 downto 0):= "0000000000000";
	    input_a_int   : out unsigned(15 downto 0):= "0000000000000000";
       output_a_int   : in unsigned(15 downto 0) := "0000000000000000";
		 colour : out unsigned(1 downto 0);
		 Direction : in std_logic_vector(1 downto 0)
		 );
end game_logic;

architecture Behavioral of game_logic is


signal head_cell : unsigned(12 downto 0);-- := to_unsigned(2440, head_cell'length); -- cell 2440
signal tail_cell : unsigned(12 downto 0);-- := to_unsigned(2440, tail_cell'length); -- cell 2440 (same start location as head)
signal next_head_cell : unsigned(12 downto 0);-- := to_unsigned(2360, next_head_cell'length);  -- cell 2360
signal next_tail_cell : unsigned(12 downto 0);-- := to_unsigned(2360, next_tail_cell'length);  -- cell 2360
signal birth_time : unsigned(4 downto 0);-- := to_unsigned(5, birth_time'length); -- 5 seconds
signal seconds : unsigned(19 downto 0);
signal head_direction : unsigned(1 downto 0) := "00"; -- moving up
signal tail_direction : unsigned(1 downto 0) := "00"; -- moving up
signal speed : unsigned(4 downto 0) := "11111"; -- slowest speed
signal score : unsigned(13 downto 0);
signal timer : unsigned(13 downto 0);
signal color : unsigned (1 downto 0);
                                      
begin




EN_int <= '1';
colour <= color;
 

 p_cell : process (clk25, ext_reset)
  begin  -- process p_cell
    if ext_reset = '1' then               -- asynchronous reset (active low)
      head_cell <= to_unsigned(2440, head_cell'length);
		tail_cell <= to_unsigned(2440, tail_cell'length);
		birth_time <= to_unsigned(5, birth_time'length);
		seconds <= to_unsigned(0, seconds'length);
		head_direction <= to_unsigned(0, head_direction'length); -- moving up
		tail_direction <= to_unsigned(0, tail_direction'length); -- moving up
		speed <= "11111";  -- slowest speed
    elsif clk25'event and clk25 = '1' then    -- rising clock edge
                                      
		

    end if;
  end process p_cell;

-- p_timer : process (clk25, ext_reset)
-- variable cnt: integer;
-- begin
--        if ext_reset = '1' then               -- asynchronous reset (active low)
--        --add resets for timer and score
--    elsif clk25'event and clk25 = '1' then    -- rising clock edge
--cnt := cnt + 1;
--if cnt = 25000000 then
--color <= color + 1;
--timer <= timer + 1;
--cnt := 0;
--end if;
--end if;
-- end process p_timer;
 
 p_movesnake : process (clk25, ext_reset, Direction)
 begin
         if ext_reset = '1' then               -- asynchronous reset (active low)
        --add resets for Direction
    elsif clk25'event and clk25 = '1' then    -- rising clock edge
		
			if (Direction = "00") then
			 color <= "00";
			elsif (Direction = "01") then
			 color <= "01";
			elsif (Direction = "10") then
			 color <= "10";
			elsif (Direction = "11") then
			 color <= "11";
		end if;
		end if;
 
 end process p_movesnake;


end Behavioral;

