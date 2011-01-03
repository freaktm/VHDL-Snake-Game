--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the ram mux for the game logic
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
    input_a           : out unsigned(11 downto 0);
    output_a          : in  unsigned(11 downto 0);
    check_read_data   : out unsigned(11 downto 0);
    check_cell        : in  unsigned(12 downto 0);
    head_write_data   : in  unsigned(11 downto 0);
    head_cell         : in  unsigned(12 downto 0);
    corner_write_data : in  unsigned(11 downto 0);
    corner_cell       : in  unsigned(12 downto 0);
    tail_read_data    : out unsigned(11 downto 0);
    tail_write_data   : in  unsigned(11 downto 0);
    tail_cell         : in  unsigned(12 downto 0);
    score_write_data  : in  unsigned(11 downto 0);
    score_cell        : in  unsigned(12 downto 0);
    reset_data        : in  unsigned(11 downto 0);
    reset_cell        : in  unsigned(12 downto 0)
    );
end ram_mux;




architecture Behavioral of ram_mux is
  
  signal   write_enable  : std_logic;
  signal   address_a_int : unsigned(12 downto 0);
  signal   input_a_int   : unsigned(11 downto 0);
  signal   output_a_int  : unsigned(11 downto 0);
  constant WE_EN         : std_logic := '1';
  constant WE_OFF        : std_logic := '0';
  
  
begin

  
  input_a      <= input_a_int;
  address_a    <= address_a_int;
  output_a_int <= output_a;
  WEA          <= write_enable;



  with gamelogic_state select
    input_a_int <=
    head_write_data   when HEAD,
    corner_write_data when CORNER,
    tail_write_data   when TAIL_WRITE,
    score_write_data  when SCORE,
    reset_data        when others;

  with gamelogic_state select
    address_a_int <=
    head_cell   when HEAD,
    corner_cell when CORNER,
    tail_cell   when TAIL_READ,
    tail_cell   when TAIL_WRITE,
    score_cell  when SCORE,
    reset_cell  when RESET,
    check_cell  when others;


  with gamelogic_state select
    write_enable <=
    WE_EN  when HEAD,
    WE_EN  when TAIL_WRITE,
    WE_EN  when RESET,
    WE_EN  when CORNER,
    WE_EN  when SCORE,
    WE_OFF when others;


  tail_read_data  <= output_a_int;
  check_read_data <= output_a_int;
  

end Behavioral;
