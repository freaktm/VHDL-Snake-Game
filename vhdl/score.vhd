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
    ext_reset       : in  std_logic;
    clk25           : in  std_logic;
    clk_slow        : in  std_logic;
    gamelogic_state : in  gamelogic_state_t;
    score_address   : out unsigned(12 downto 0);
    score_data      : out unsigned(11 downto 0);
    score_done      : out std_logic
    );
end score_logic;



architecture Behavioral of score_logic is


  signal score_done_int    : std_logic                    := '0';
  signal score_address_int : unsigned(12 downto 0)        := (others => '0');
  signal score_data_int    : unsigned(11 downto 0)        := (others => '0');
  signal score_tick        : std_logic                    := '0';
  signal score1_done       : std_logic                    := '0';
  signal score2_done       : std_logic                    := '0';
  signal score3_done       : std_logic                    := '0';
  signal score1_max        : std_logic                    := '0';
  signal score2_max        : std_logic                    := '0';
  signal score3_max        : std_logic                    := '0';
  signal score1            : std_logic_vector(3 downto 0) := (others => '0');
  signal score2            : std_logic_vector(3 downto 0) := (others => '0');
  signal score3            : std_logic_vector(3 downto 0) := (others => '0');
  signal score4            : std_logic_vector(3 downto 0) := (others => '0');
  signal tick_done         : std_logic                    := '0';

  type   score_state_t is (IDLE, SCORE1, SCORE2, SCORE3, SCORE4);
  signal score_state : score_state_t := IDLE;
  
begin

  score_done    <= score_done_int;
  score_address <= score_address_int;
  score_data    <= score_data_int;

-- purpose: update the score
-- type   : sequential
-- inputs : clk_slow, ext_reset
  p_update_score : process (clk_slow, ext_reset)
    variable cnt : integer := 0;
  begin  -- process p_update_score
    if ext_reset = '1' then             -- asynchronous reset (active high)
      cnt        := 0;
      score_tick <= '0';
      tick_done  <= '0';
    elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
      if (gamelogic_state = SCORE) then
        if (score_state = IDLE) then
          if (cnt = 15) then
            score_tick <= '1';
            cnt        := 0;
            tick_done  <= '0';
          else
            cnt        := cnt + 1;
            score_tick <= '0';
            tick_done  <= '1';
          end if;
        else
          score_tick <= '0';
          tick_done  <= '0';
        end if;
      end if;
    end process p_update_score;








      -- purpose: controls which state the game logic is in
-- type   : sequential
-- inputs : clk25, ext_reset, tick, head_done, corner_done, corner, score, tail_done, crashed, reset_done
-- outputs: state
      p_state_machine : process (clk25, ext_reset)
      begin  -- process p_state_machine
        if ext_reset = '1' then         -- asynchronous reset (active high)
          score_state <= IDLE;
        elsif clk25'event and clk25 = '1' then  -- rising clock edge
          case score_state is
            when IDLE =>
              if scoretick = '1' then
                score_state <= SCORE1;
              end if;
            when SCORE1 =>
              if (score1_max = '1') then
                score_state <= SCORE2;
              elsif (score1_done = '1') then
                score_state    <= IDLE;
                score_done_int <= '1';
              end if;
            when SCORE2 =>
              if (score2_max = '1') then
                score_state <= SCORE3;
              elsif (score2_done = '1') then
                score_state    <= IDLE;
                score_done_int <= '1';
              end if;
            when SCORE3 =>
              if (score3_max = '1') then
                score_state <= SCORE4;
              elsif (score3_done = '1') then
                score_state    <= IDLE;
                score_done_int <= '1';
              end if;
            when SCORE4 =>
              if (score4_done = '1') then
                score_state    <= IDLE;
                score_done_int <= '1';
              end if;
          end case;
        end if;

      end process p_state_machine;




      
    end Behavioral;
