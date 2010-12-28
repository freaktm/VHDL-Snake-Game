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
use work.gamelogic_pkg.all;

entity check_logic is
  port(
    gamelogic_state       : in  gamelogic_state_t;
    clk_slow              : in  std_logic;
    ext_reset             : in  std_logic;
    address_a_check       : out unsigned(12 downto 0);
    check_read_data       : in  unsigned(11 downto 0);
    check_done            : out std_logic;
    keyboard              : in  unsigned(2 downto 0);
    crashed               : out std_logic;
    nochange              : out std_logic;
    current_direction_out : out unsigned(2 downto 0);
    old_direction_out     : out unsigned(2 downto 0);
    next_cell             : out unsigned(12 downto 0)
    );
end check_logic;

architecture Behavioral of check_logic is

  signal current_direction_int : unsigned(2 downto 0);
  signal next_direction        : unsigned(2 downto 0);
  signal current_cell          : unsigned(12 downto 0);
  signal next_cell_int         : unsigned(12 downto 0);
  signal checking              : unsigned(1 downto 0);

  
begin
  
  
  current_direction_out <= current_direction_int;

  next_direction <= keyboard;
  next_cell      <= next_cell_int;


  --purpose: checks if the snake has crashed into a border or itself
  --type   : sequential
  --inputs : clk25, ext_reset, state, next_direction, output_a_int, crash_result_ready
  --outputs: crash_test, crashed
  p_collision_checker : process (clk_slow, ext_reset)
  begin  -- process p_collision_checker
    if (ext_reset = '1') then           --  asynchronous reset (active high)
      crashed               <= '0';
      check_done            <= '0';
      nochange              <= '1';
      checking              <= "00";
      current_cell          <= to_unsigned(2520, current_cell'length);
      current_direction_int <= "001";   -- reset to moving up
      next_cell_int         <= to_unsigned(2440, next_cell_int'length);
    elsif (clk_slow'event and clk_slow = '1') then
      if (gamelogic_state = CHECK) then
        old_direction_out <= current_direction_int;
        if (current_direction_int /= next_direction) then
          nochange <= '0';
        else
          nochange <= '1';
        end if;
        if (checking = "00") then
          check_done            <= '0';
          checking              <= "01";
          current_direction_int <= next_direction;
          if (next_direction = "001") then
            next_cell_int <= to_unsigned(to_integer(current_cell) - 80, next_cell_int'length);
          elsif (next_direction = "010") then
            next_cell_int <= to_unsigned(to_integer(current_cell) + 1, next_cell_int'length);
          elsif (next_direction = "011") then
            next_cell_int <= to_unsigned(to_integer(current_cell) + 80, next_cell_int'length);
          elsif (next_direction = "100") then
            next_cell_int <= to_unsigned(to_integer(current_cell) - 1, next_cell_int'length);
          end if;
			 elsif (checking = "01") then
			 checking <= "10";
          address_a_check <= next_cell_int;
          current_cell    <= next_cell_int;
        elsif (checking = "10") then
          checking <= "11";
          if (to_integer(check_read_data) = 0) then
            crashed <= '0';
          else
            crashed <= '0';
          end if;
        elsif (checking = "11") then
          checking   <= "00";
          check_done <= '1';
        end if;
      else
        check_done <= '0';
        crashed    <= '0';
        checking   <= "00";
      end if;
    end if;
  end process p_collision_checker;



end Behavioral;
