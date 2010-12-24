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

entity reset_logic is
  port(
    gamelogic_state  : in  gamelogic_state_t;
    clk25            : in  std_logic;
    ext_reset        : in  std_logic;
    address_a_reset  : out unsigned(12 downto 0);
    reset_write_data : out unsigned(11 downto 0);
    reset_done       : out std_logic;
    keyboard         : in  unsigned(2 downto 0)
    );
end reset_logic;

architecture Behavioral of reset_logic is




begin
  

  p_reset_state : process (gamelogic_state, clk25, ext_reset)
    variable ramcnt_i : integer;
    variable ramcnt_j : integer;
  begin
    
    if (ext_reset = '1') then           --asynchronous reset (active high)
      reset_done <= '0';
    elsif clk25'event and clk25 = '1' then
      if (gamelogic_state = RESET) then
        reset_write_data <= (others => '0');
        ramcnt_i         := ramcnt_i + 1;
        if (ramcnt_i = 80) then
          ramcnt_j := ramcnt_j + 1;
          ramcnt_i := 0;
          if (ramcnt_j = 55) then
            --     reset_done <= '1';
            ramcnt_i := 0;
            ramcnt_j := 0;
          end if;
        elsif (ramcnt_i > 0) and (ramcnt_i < 79) and (ramcnt_j > 0) and (ramcnt_j < 55) then
          address_a_reset  <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a_reset'length);
          reset_write_data <= (others => '0');
        else
          address_a_reset  <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a_reset'length);
          reset_write_data <= to_unsigned(8, reset_write_data'length);
        end if;
      else
        reset_done <= '0';
      end if;
    end if;
  end process p_reset_state;





end Behavioral;
