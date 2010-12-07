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

entity ram_mux is
  port(
    clk25        : in  std_logic;
    ext_reset    : in  std_logic;

    gamelogic_state : in gamelogic_state_t;
    
--    head_en      : in  std_logic;
--    tail_en      : in  std_logic;
--    corner_en    : in  std_logic;
--    score_en     : in  std_logic;

    WEA          : out std_logic;
    address_a    : out unsigned(12 downto 0);
    input_a      : out unsigned(15 downto 0);
    task_done    : out std_logic;
    reset_en     : in  std_logic;
    request_read : in  std_logic
    );
end ram_mux;




architecture Behavioral of ram_mux is
  
  signal write_enable  : std_logic;
  signal address_a_int : unsigned(12 downto 0);
  signal input_a_int   : unsigned(15 downto 0);
  signal waiting       : std_logic;

  
begin
  -- purpose: updates the ram entries for the video display also controls the reading
  -- type   : sequential
  -- inputs : clk25, ext_reset, WE_head, WE_tail, WE_corner, write_data_head,
  -- write_data_tail, write_data_corner, head_cell, corner_cell, tail_cell,
  -- WE_score1, WE_Score2, WE_score3, WE_score4, write_data_score1, write_data_score2, write_data_score3, write_data_score4
  -- outputs : address_a_int, write_enable, input_a_int, write_job
  
  input_a   <= input_a_int;
  address_a <= address_a_int;
  WEA       <= write_enable;

  p_process_request : process ()
    variable ramcnt_i : integer;
    variable ramcnt_j : integer;
  begin  -- process p_cellupdate
    if (ext_reset = '1') then           -- asynchronous reset (active high)
      reset_done   <= '0';
      task_done    <= '0';
      write_enable <= '0';
      address_a    <= (others => '0');
      input_a      <= (others => '0');
      accessing    <= '0';
    elsif clk25'event and clk25 = '1' and reset_en = '0' then  -- rising clock edge
      -- RESET STATE OF RAM                                                      
      if (reset_en = '1') then
        write_enable <= '1';
        input_a_int  <= (others => '0');
        ramcnt_i     := ramcnt_i + 1;
        if (ramcnt_i = 80) then
          ramcnt_j := ramcnt_j + 1;
          ramcnt_i := 0;
          if (ramcnt_j = 55) then
            reset_done <= '1';
            ramcnt_i   := 0;
            ramcnt_j   := 0;
            write_enable <= '0';
          end if;
        end if;
        if (ramcnt_i > 0) and (ramcnt_i < 79) and (ramcnt_j > 0) and (ramcnt_j < 55) then
          address_a <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a'length);
          input_a   <= (others => '0');
        else
          address_a <= to_unsigned((ramcnt_j*80) + ramcnt_i, address_a'length);
          input_a   <= to_unsigned(8, input_a'length);
        end if;
        
      elsif (head_en = '1') then        -- HEAD STATE OF MUX
        if (request_read = '1') then
          write_enable <= '0';
        else
          write_enable <= '1';
        end if;
        if (waiting = '0') then
          task_done     <= '0';
          input_a_int   <= head_write_data;
          address_a_int <= head_cell;
          waiting       <= '1';
        else
          waiting   <= '0';
          task_done <= '1';
        end if;       
      elsif (corner_en = '1') then      -- CORNER STATE OF MUX
        if (waiting = '0') then
          write_enable <= '1';
          task_done     <= '0';
          input_a_int   <= corner_write_data;
          address_a_int <= corner_cell;
          waiting       <= '1';
        else
          write_enable <= '0';
          waiting   <= '0';
          task_done <= '1';
        end if;
      elsif (tail_en = '1') then        -- TAIL STATE OF MUX
        if (waiting = '0') then
          write_enable <= '1';
          task_done     <= '0';
          input_a_int   <= corner_write_data;
          address_a_int <= corner_cell;
          waiting       <= '1';
        else
          write_enable <= '0';
          waiting   <= '0';
          task_done <= '1';
        end if;
      elsif (score_en = '1') then       -- SCORE STATE OF MUX
        if (waiting = '0') then
          write_enable <= '1';
          task_done     <= '0';
          input_a_int   <= score_write_data;
          address_a_int <= score_cell;
          waiting       <= '1';
        else
          write_enable <= '0';
          waiting   <= '0';
          task_done <= '1';
        end if;
      else
        write_enable <= '0';
      end if;
  
    end process p_cellupdate;

    end Behavioral;
