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
use work.gamelogic_pkg.all;             -- game state package

entity head_logic is
  port(
    clk_slow             : in  std_logic;
    ext_reset            : in  std_logic;
    gamelogic_state      : in  gamelogic_state_t;
    address_a_head       : out unsigned(12 downto 0);
    head_write_data      : out unsigned(11 downto 0);
    head_done            : out std_logic;
    next_cell            : in  unsigned(12 downto 0);
    current_direction_in : in  unsigned(2 downto 0)
    );
end head_logic;

architecture Behavioral of head_logic is


  signal snake_character : unsigned(8 downto 0)         := (others => '0');
  signal checking        : std_logic_vector(1 downto 0) := (others => '0');
  
  
begin


  -- purpose: update head movement
  -- type   : sequential
  -- inputs : clk_slow, ext_reset
  -- outputs: 
  p_process_head : process (clk_slow, ext_reset)
  begin  -- process
    if ext_reset = '1' then             -- asynchronous reset (active high)
      checking        <= (others => '0');
      head_done       <= '0';
      snake_character <= to_unsigned(3*8, snake_character'length);
      
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge


      if (gamelogic_state = HEAD) then

        if (checking = "00") then
          
          checking <= "01";
          if (current_direction_in = "001") or (current_direction_in = "011") then
            snake_character <= to_unsigned(3*8, snake_character'length);
          elsif (current_direction_in = "010") or (current_direction_in = "100") then
            snake_character <= to_unsigned(2*8, snake_character'length);
          end if;

        elsif (checking = "01") then
          checking        <= "10";
          address_a_head  <= next_cell;
          head_write_data <= current_direction_in & snake_character;
        elsif (checking = "10") then
          checking  <= (others => '0');
          head_done <= '1';
        end if;

      else
        checking  <= (others => '0');
        head_done <= '0';
      end if;
      
    end if;
  end process;
  
end Behavioral;
