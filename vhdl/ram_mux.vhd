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
    gamelogic_state   : in  gamelogic_state_t;
    WEA               : out std_logic;
    address_a         : out unsigned(12 downto 0);
    input_a           : out unsigned(15 downto 0);
	 check_read_data : out unsigned(15 downto 0);
	 check_cell : in unsigned(12 downto 0);
    head_write_data   : in  unsigned(15 downto 0);
    head_cell         : in  unsigned(12 downto 0);
    corner_write_data : in  unsigned(15 downto 0);
    corner_cell       : in  unsigned(12 downto 0);
	 tail_read_data	: out unsigned(15 downto 0);
    tail_write_data   : in  unsigned(15 downto 0);
    tail_cell         : in  unsigned(12 downto 0);
    score_write_data  : in  unsigned(15 downto 0);
    score_cell        : in  unsigned(12 downto 0);
    reset_data        : in  unsigned(15 downto 0);
    reset_cell        : in  unsigned(12 downto 0)
    );
end ram_mux;




architecture Behavioral of ram_mux is
  
  signal write_enable  : std_logic;
  signal address_a_int : unsigned(12 downto 0);
  signal input_a_int   : unsigned(15 downto 0);
  signal output_a_int : unsigned(15 downto 0);
  
  signal state : gamelogic_state_t;
  
begin
  -- purpose: updates the ram entries for the video display also controls the reading
  -- type   : combinational
  -- inputs : clk25, ext_reset, WE_head, WE_tail, WE_corner, write_data_head,
  -- write_data_tail, write_data_corner, head_cell, corner_cell, tail_cell,
  -- WE_score1, WE_Score2, WE_score3, WE_score4, write_data_score1, write_data_score2, write_data_score3, write_data_score4
  -- outputs : address_a_int, write_enable, input_a_int, write_job
  
  input_a   <= input_a_int;
  address_a <= address_a_int;
  WEA       <= write_enable;

  p_process_request : process (gamelogic_state, reset_data, reset_cell, head_write_data, head_cell, corner_write_data, corner_cell, tail_cell, tail_write_data, score_write_data, score_cell)
    variable ramcnt_i : integer;
    variable ramcnt_j : integer;
  begin  -- process p_cellupdate
    if gamelogic_state = RESET then  -- RESET STATE OF RAM                                                      
      input_a_int   <= reset_data;
      address_a_int <= reset_cell;
      write_enable  <= '1';
      
    elsif (gamelogic_state = HEAD) then  -- HEAD STATE OF MUX
      input_a_int   <= head_write_data;
      address_a_int <= head_cell;
      write_enable <= '1';
      
      
    elsif (gamelogic_state = CORNER) then  -- CORNER STATE OF MUX
      input_a_int   <= corner_write_data;
      address_a_int <= corner_cell;
      write_enable  <= '1';
		
		elsif (gamelogic_state = READTAIL) then  -- CORNER STATE OF MUX
      address_a_int <= tail_cell;
      write_enable  <= '0';
      
    elsif (gamelogic_state = TAIL) then  -- TAIL STATE OF MUX

      input_a_int   <= tail_write_data;
      address_a_int <= tail_cell;
      write_enable  <= '1';
      
    elsif (gamelogic_state = SCORE) then  -- SCORE STATE OF MUX

      input_a_int   <= score_write_data;
      address_a_int <= score_cell;
      write_enable  <= '1';
      
    else
      write_enable <= '0';              -- MUX IDLE
    end if;
    
  end process p_process_request;

end Behavioral;
