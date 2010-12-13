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

entity score_logic is
  port(
    gamelogic_state : in  gamelogic_state_t;
    score  : out unsigned(13 downto 0)
    );
end score_logic;



architecture Behavioral of score_logic is


signal score_int : unsigned(13 downto 0);

begin
  
score <= score_int;


end Behavioral;

