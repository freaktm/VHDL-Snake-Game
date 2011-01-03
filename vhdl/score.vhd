--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the score logic for the game.
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

entity score_logic is
  port(
    gamelogic_state : in  gamelogic_state_t;
    score           : out unsigned(13 downto 0);
    score_done      : out std_logic
    );
end score_logic;



architecture Behavioral of score_logic is


  signal score_int      : unsigned(13 downto 0) := (others => '0');
  signal score_done_int : std_logic := '1';  --scoring disabled

begin

  score      <= score_int;
  score_done <= score_done_int;



end Behavioral;

