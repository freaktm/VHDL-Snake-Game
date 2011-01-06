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
  signal score1_data       : unsigned(11 downto 0)        := to_unsigned(24*8, 12);  -- 0;
  signal score2_data       : unsigned(11 downto 0)        := to_unsigned(24*8, 12);  -- 0;
  signal score3_data       : unsigned(11 downto 0)        := to_unsigned(24*8, 12);  -- 0;
  signal score4_data       : unsigned(11 downto 0)        := to_unsigned(24*8, 12);  -- 0;
  signal score1_address    : unsigned(12 downto 0)        := to_unsigned(4568, 13);  -- 0;
  signal score2_address    : unsigned(12 downto 0)        := to_unsigned(4569, 13);  -- 0;
  signal score3_address    : unsigned(12 downto 0)        := to_unsigned(4570, 13);  -- 0;
  signal score4_address    : unsigned(12 downto 0)        := to_unsigned(4571, 13);  -- 0;
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
  signal write_state       : std_logic_vector(1 downto 0) := (others => '0');

  type   score_state_t is (IDLE, SCORE1, SCORE2, SCORE3, SCORE4, SCORE_WRITE);
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




      p_write_score_data : process (clk_slow, ext_reset)
      begin  -- process p_write_score_data
        if ext_reset = '1' then         -- asynchronous reset (active high)
          score_done_int    <= '0';
          score_data_int    <= (others => '0');
          score_address_int <= (others => '0');
          write_state       <= (others => '0');
        elsif clk_slow'event and clk_slow = '1' then  -- rising clock edge
          if (score_state = SCORE_WRITE) then
            if (write_state = "00") then
              write_state       <= "01";
              score_address_int <= score1_address;
              score_data_int    <= score1_data;
            elsif (write_state = "01") then
              write_state       <= "10";
              score_address_int <= score2_address;
              score_data_int    <= score2_data;
            elsif (write_state = "10") then
              write_state       <= "11";
              score_address_int <= score3_address;
              score_data_int    <= score3_data;
            elsif (write_state = "11") then
              write_state       <= "00";
              score_address_int <= score4_address;
              score_data_int    <= score4_data;
              score_done_int    <= '1';
            end if;
          else
            score_done_int    <= '0';
            score_address_int <= score1_address;
            score_data_int    <= score1_data;
            write_state       <= (others => '0');
          end if;
        end if;
      end process p_write_score_data;



      p_score1_data : process (score1)
      begin  -- process score1 output data
        case score1 is
          when "0000" =>
            score1_data <= to_unsigned(24*8, 12);  -- 0
          when "0000" =>
            score1_data <= to_unsigned(25*8, 12);  -- 1
          when "0000" =>
            score1_data <= to_unsigned(26*8, 12);  -- 2
          when "0000" =>
            score1_data <= to_unsigned(27*8, 12);  -- 3
          when "0000" =>
            score1_data <= to_unsigned(28*8, 12);  -- 4
          when "0000" =>
            score1_data <= to_unsigned(29*8, 12);  -- 5
          when "0000" =>
            score1_data <= to_unsigned(30*8, 12);  -- 6
          when "0000" =>
            score1_data <= to_unsigned(31*8, 12);  -- 7
          when "0000" =>
            score1_data <= to_unsigned(32*8, 12);  -- 8
          when "0000" =>
            score1_data <= to_unsigned(33*8, 12);  -- 9
          when others =>
            score1_data <= (others => '0');
        end case;
      end process p_score1_data;


      p_score2_data : process (score2)
      begin  -- process score2 output data
        case score2 is
          when "0000" =>
            score2_data <= to_unsigned(24*8, 12);  -- 0
          when "0000" =>
            score2_data <= to_unsigned(25*8, 12);  -- 1
          when "0000" =>
            score2_data <= to_unsigned(26*8, 12);  -- 2
          when "0000" =>
            score2_data <= to_unsigned(27*8, 12);  -- 3
          when "0000" =>
            score2_data <= to_unsigned(28*8, 12);  -- 4
          when "0000" =>
            score2_data <= to_unsigned(29*8, 12);  -- 5
          when "0000" =>
            score2_data <= to_unsigned(30*8, 12);  -- 6
          when "0000" =>
            score2_data <= to_unsigned(31*8, 12);  -- 7
          when "0000" =>
            score2_data <= to_unsigned(32*8, 12);  -- 8
          when "0000" =>
            score2_data <= to_unsigned(33*8, 12);  -- 9
          when others =>
            score2_data <= (others => '0');
        end case;
      end process p_score2_data;


      p_score3_data : process (score3)
      begin  -- process score3 output data
        case score3 is
          when "0000" =>
            score3_data <= to_unsigned(24*8, 12);  -- 0
          when "0000" =>
            score3_data <= to_unsigned(25*8, 12);  -- 1
          when "0000" =>
            score3_data <= to_unsigned(26*8, 12);  -- 2
          when "0000" =>
            score3_data <= to_unsigned(27*8, 12);  -- 3
          when "0000" =>
            score3_data <= to_unsigned(28*8, 12);  -- 4
          when "0000" =>
            score3_data <= to_unsigned(29*8, 12);  -- 5
          when "0000" =>
            score3_data <= to_unsigned(30*8, 12);  -- 6
          when "0000" =>
            score3_data <= to_unsigned(31*8, 12);  -- 7
          when "0000" =>
            score3_data <= to_unsigned(32*8, 12);  -- 8
          when "0000" =>
            score3_data <= to_unsigned(33*8, 12);  -- 9
          when others =>
            score3_data <= (others => '0');
        end case;
      end process p_score3_data;



      p_score4_data : process (score4)
      begin  -- process score4 output data
        case score4 is
          when "0000" =>
            score4_data <= to_unsigned(24*8, 12);  -- 0
          when "0000" =>
            score4_data <= to_unsigned(25*8, 12);  -- 1
          when "0000" =>
            score4_data <= to_unsigned(26*8, 12);  -- 2
          when "0000" =>
            score4_data <= to_unsigned(27*8, 12);  -- 3
          when "0000" =>
            score4_data <= to_unsigned(28*8, 12);  -- 4
          when "0000" =>
            score4_data <= to_unsigned(29*8, 12);  -- 5
          when "0000" =>
            score4_data <= to_unsigned(30*8, 12);  -- 6
          when "0000" =>
            score4_data <= to_unsigned(31*8, 12);  -- 7
          when "0000" =>
            score4_data <= to_unsigned(32*8, 12);  -- 8
          when "0000" =>
            score4_data <= to_unsigned(33*8, 12);  -- 9
          when others =>
            score4_data <= (others => '0');
        end case;
      end process p_score4_data;



-- purpose: updates the score display variables
-- type   : sequential
-- inputs : clk_25, ext_reset
-- outputs: 
      p_score1 : process (clk_25, ext_reset)
      begin  -- process p_score1
        if ext_reset = '1' then         -- asynchronous reset (active high)
          score1_done <= '0';
          score1_max  <= '0';
          score1      <= (others => '0');
          score2_done <= '0';
          score2_max  <= '0';
          score2      <= (others => '0');
          score3_done <= '0';
          score3_max  <= '0';
          score3      <= (others => '0');
          score4_done <= '0';
          score4_max  <= '0';
          score4      <= (others => '0');
        elsif clk_25'event and clk_25 = '1' then  -- rising clock edge
          if (score_state = SCORE1) then
            score1 <= score1 + 1;
            if (score1 = "1010") then
              score1     <= (others => '0');
              score1_max <= '1';
            else
              score1_done <= '1';
            end if;
          else
            score1_done <= '0';
            score1_max  <= '0';
          end if;
          if (score_state = SCORE2) then
            score2 <= score2 + 1;
            if (score2 = "1010") then
              score2     <= (others => '0');
              score2_max <= '1';
            else
              score2_done <= '1';
            end if;
          else
            score2_done <= '0';
            score2_max  <= '0';
          end if;
          if (score_state = SCORE3) then
            score3 <= score3 + 1;
            if (score3 = "1010") then
              score3     <= (others => '0');
              score3_max <= '1';
            else
              score3_done <= '1';
            end if;
          else
            score3_done <= '0';
            score3_max  <= '0';
          end if;
          if (score_state = SCORE4) then
            score4      <= score4 + 1;
            score4_done <= '1';
          end if;
        else
          score4_done <= '0';
        end if;

      end if;
    end process p_score1;





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
              score_write <= '0';
              if scoretick = '1' then
                score_state <= SCORE1;
              elsif tick_done = '1' then
                score_state <= SCORE_WRITE;
              end if;
            when SCORE1 =>
              if (score1_max = '1') then
                score_state <= SCORE2;
              elsif (score1_done = '1') then
                score_state <= SCORE_WRITE;
              end if;
            when SCORE2 =>
              if (score2_max = '1') then
                score_state <= SCORE3;
              elsif (score2_done = '1') then
                score_state <= SCORE_WRITE;
              end if;
            when SCORE3 =>
              if (score3_max = '1') then
                score_state <= SCORE4;
              elsif (score3_done = '1') then
                score_state <= SCORE_WRITE;
              end if;
            when SCORE4 =>
              if (score4_done = '1') then
                score_state <= SCORE_WRITE;
              end if;
            when SCORE_WRITE =>
              if (score_done_int = '1') then
                score_state <= IDLE;
              end if;
          end case;
        end if;

      end process p_state_machine;





    end Behavioral;
