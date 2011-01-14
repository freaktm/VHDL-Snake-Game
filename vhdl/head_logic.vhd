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
    head_addr_done       : out std_logic;
    next_cell            : in  unsigned(12 downto 0);
    changed_dir          : in  std_logic;
    current_direction_in : in  unsigned(2 downto 0)
    );
end head_logic;

architecture Behavioral of head_logic is


  signal snake_character     : unsigned(8 downto 0)  := (others => '0');
  signal address_a_head_int  : unsigned(12 downto 0) := (others => '0');
  signal head_write_data_int : unsigned(11 downto 0) := (others => '0');
  signal head_done_int       : std_logic             := '0';
  signal head_addr_done_int  : std_logic             := '0';

  
  
  
begin


  address_a_head  <= address_a_head_int;
  head_write_data <= head_write_data_int;
  head_done       <= head_done_int;
  head_addr_done  <= head_addr_done_int;

  address_a_head_int <= next_cell;

  -- purpose: sets the address for the HEAD state to write.
  -- type   : sequential
  -- inputs : clk_slow, ext_reset
  -- outputs: 
  p_set_head_address : process (clk_slow, ext_reset)
  begin  -- process p_set_head_address
    if ext_reset = '1' then             -- asynchronous reset (active high)
      head_addr_done_int  <= '0';
      snake_character     <= to_unsigned(3*8, snake_character'length);
      head_write_data_int <= (others => '0');
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      
      if changed_dir = '0' then         -- (active low)
        if (to_integer(snake_character) = 16) then
          snake_character <= to_unsigned(3*8, snake_character'length);
        else
          snake_character <= to_unsigned(2*8, snake_character'length);
        end if;
      end if;

      if (gamelogic_state = HEAD_DATA) then
        head_write_data_int <= current_direction_in & snake_character;
        head_addr_done_int  <= '1';
      end if;
    end if;
  end process p_set_head_address;



-- purpose: update head movement
-- type   : sequential
-- inputs : clk_slow, ext_reset
-- outputs: 
  p_process_head : process (clk_slow, ext_reset)
  begin  -- process
    if ext_reset = '1' then             -- asynchronous reset (active high)
      head_done_int <= '0';
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      if (gamelogic_state = HEAD_WRITE) then
        head_done_int <= '1';
      else
        head_done_int <= '0';
      end if;
    end if;
  end process;




end Behavioral;
