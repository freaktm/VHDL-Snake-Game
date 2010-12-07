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

entity head_logic is
  port(
    clk25         : in  std_logic;
    ext_reset     : in  std_logic;
    WEA_head       : out std_logic;
    address_a_head : out unsigned(12 downto 0);
    input_a_head   : out unsigned(15 downto 0);
    output_a_head  : in  unsigned(15 downto 0);
    head_done     : out std_logic;
	 reset_en : out std_logic
    );
end game_logic;

architecture Behavioral of head_logic is


  -- HEAD STATE MACHINE SIGNALS
  type   head_state_t is (IDLE, CRASH_CHECK, CORNER, HEAD);
  signal head_state : head_state_t;
  
begin
  
  
    -- purpose: controls the HEAD state
  -- type   : sequential
  -- inputs : clk25, ext_reset, head_en, ram_data_a, Direction 
  -- outputs: reset_en, head_done
  p_head_state_machine: process (clk25, ext_reset)
  begin  -- process p_head_state_machine
    if ext_reset = '1' then             -- asynchronous reset (active high)
		head_state <= IDLE;         
    elsif clk25'event and clk25 = '1' then  -- rising clock edge
            case state is
        when IDLE =>
          if head_en = '1' then
            head_state <= CRASH_CHECK ;
          end if;
        when CRASH_CHECK =>
          if reset_en = '1' then
            head_state <= IDLE;
          elsif (no_crash = '1') and (next_direction = current_direction) then
            head_state <= HEAD;
          elsif (no_crash = '1') then
            head_state <= CORNER;
          end if;
        when CORNER =>
          if head_corner_done ='1' then
            head_state <= HEAD;
          end if;
        when HEAD =>
          if head_done = '1' then
            head_state <= IDLE;
          end if;

      end case;
    end if;
  end process p_head_state_machine;
  
  
  -- purpose: checks for crash when in CRASH_CHECK state
-- type   : combinational
-- inputs : head_state
-- outputs: no_crash, reset_en
p_check_crash: process (head_state)
begin  -- process p_check_crash
  if head_state = CRASH_CHECK then
    
  end if;
end process p_check_crash;

    end Behavioral;