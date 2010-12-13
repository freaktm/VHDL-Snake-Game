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
-- Anthonix
-- 
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.gamelogic_pkg.all;

entity check_logic is
  port(
   gamelogic_state   : in  gamelogic_state_t;
    clk25         : in  std_logic;
    ext_reset     : in  std_logic;
    address_a_check : out unsigned(12 downto 0);
    check_read_data  : in  unsigned(15 downto 0);
    check_done     : out std_logic;
	 keyboard : in unsigned(2 downto 0);
	 crashed : out std_logic;
	 nochange : out std_logic;
	 current_direction_out : out unsigned(2 downto 0);
	 next_cell : out unsigned(12 downto 0)
    );
end check_logic;

architecture Behavioral of check_logic is


 -- signal gamelogic_state : gamelogic_state_t;
  signal current_direction_int : unsigned(2 downto 0);
  signal next_direction : unsigned(2 downto 0);
  signal current_cell : unsigned(12 downto 0);
  signal next_cell_int : unsigned(12 downto 0);
  signal checking : std_logic;

  
begin
  
  
current_direction_out <= current_direction_int;
  
next_direction <= keyboard;
next_cell <= next_cell_int;


 --purpose: checks if the snake has crashed into a border or itself
 --type   : sequential
 --inputs : clk25, ext_reset, state, next_direction, output_a_int, crash_result_ready
 --outputs: crash_test, crashed
      p_collision_checker : process (clk25, ext_reset)
      begin  -- process p_collision_checker
        if (ext_reset = '1') then --  asynchronous reset (active high)
          crashed    <= '0';
			 check_done <= '0';
			 checking <= '0';
			 current_direction_int <= "001"; -- reset to moving up
        elsif clk25'event and clk25 = '1' then       --     rising clock edge
          if (gamelogic_state = CHECK)then
			  if (current_direction_int /= next_direction) then
			    nochange <= '0';
				 else
				 nochange <= '1';
				 end if;
            if (checking = '0') then
						checking <= '1';
						current_direction_int <= next_direction;
						if (next_direction = "001") then
                  next_cell_int  <= to_unsigned(to_integer(current_cell) - 80, next_cell_int'length);
						elsif (next_direction = "010") then
						next_cell_int  <= to_unsigned(to_integer(current_cell) + 1, next_cell_int'length);
						elsif (next_direction = "011") then
						next_cell_int  <= to_unsigned(to_integer(current_cell) + 80, next_cell_int'length);
						elsif (next_direction = "100") then
						next_cell_int  <= to_unsigned(to_integer(current_cell) - 1, next_cell_int'length);
						end if;
						current_cell <= next_cell_int;
						address_a_check <= next_cell_int;
            elsif (checking = '1') then
				    checking <= '0';
              if (to_integer(check_read_data) /= 0) then
                crashed <= '1';
              else
                check_done <= '1';
              end if;
				  
            end if;
				else
				check_done <= '0';
				crashed <= '0';
				checking <= '0';
				end if;
          end if;
       end process p_collision_checker;



    end Behavioral;