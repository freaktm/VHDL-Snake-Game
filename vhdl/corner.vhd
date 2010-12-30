--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
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

entity corner_logic is
  port(
    ext_reset            : in  std_logic;
    clk_slow             : in  std_logic;
    gamelogic_state      : in  gamelogic_state_t;
    address_a_corner     : out unsigned(12 downto 0);
    corner_write_data    : out unsigned(11 downto 0);
    corner_done          : out std_logic;
    next_cell            : in  unsigned(12 downto 0);
    old_direction_in     : in  unsigned(2 downto 0);
    current_direction_in : in  unsigned(2 downto 0)
    );
end corner_logic;

architecture Behavioral of corner_logic is


  signal snake_character       : unsigned(8 downto 0)         := (others => '0');
  signal counting              : std_logic_vector(1 downto 0) := "00";
  signal corner_done_int       : std_logic                    := '0';
  signal corner_write_data_int : unsigned(11 downto 0)        := (others <= '0');
  
begin
  
  address_a_corner  <= next_cell;
  corner_done       <= corner_done_int;
  corner_write_data <= corner_write_data_int;

  -- purpose: generates the corner cell
  -- type   : sequential
  -- inputs : clk_slow, ext_reset
  -- outputs: 
  p_process_corner : process (clk_slow, ext_reset)
  begin  -- process p_process_corner
    if ext_reset = '1' then             -- asynchronous reset (active high)
      snake_character       <= to_unsigned(5*8, snake_character'length);
      corner_done_int       <= '0';
      counting              <= "00";
      corner_write_data_int <= (others => '0');
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      if (gamelogic_state = CORNER) then
        if ((current_direction_in = "001") and (old_direction_in = "010")) or ((current_direction_in = "100") and (old_direction_in = "011")) then
          snake_character <= to_unsigned(5*8, snake_character'length);
        elsif ((current_direction_in = "010") and (old_direction_in = "011")) or ((current_direction_in = "001") and (old_direction_in = "100")) then
          snake_character <= to_unsigned(4*8, snake_character'length);
        elsif ((current_direction_in = "010") and (old_direction_in = "001")) or ((current_direction_in = "011") and (old_direction_in = "100")) then
          snake_character <= to_unsigned(6*8, snake_character'length);
        elsif ((current_direction_in = "011") and (old_direction_in = "010")) or ((current_direction_in = "100") and (old_direction_in = "001")) then
          snake_character <= to_unsigned(7*8, snake_character'length);
        else
          snake_character <= to_unsigned(7*8, snake_character'length);
        end if;

        corner_write_data_int <= current_direction_in & snake_character;
        corner_done_int       <= '1';
      else
        corner_done_int <= '0';
      end if;
    end if;
  end process p_process_corner;




end Behavioral;
