-------------------------------------------------------------------------------
-- Title      : Testbench for design "check_logic"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : check_logic_tb.vhd
-- Author     : CompSci temp account 2  <cs002@nui.cs.waikato.ac.nz>
-- Company    : 
-- Created    : 2010-12-17
-- Last update: 2010-12-17
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010-12-17  1.0      cs002	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gamelogic_pkg.all;
-------------------------------------------------------------------------------

entity check_logic_tb is

end check_logic_tb;

-------------------------------------------------------------------------------

architecture tb of check_logic_tb is

  component check_logic
    port (
      gamelogic_state       : in  gamelogic_state_t;
      clk25                 : in  std_logic := '0';
      ext_reset             : in  std_logic := '0';
      address_a_check       : out unsigned(12 downto 0);
      check_read_data       : in  unsigned(11 downto 0);
      check_done            : out std_logic := '0';
      keyboard              : in  unsigned(2 downto 0);
      crashed               : out std_logic := '0';
      nochange              : out std_logic := '0';
      current_direction_out : out unsigned(2 downto 0);
      old_direction_out     : out unsigned(2 downto 0);
      next_cell             : out unsigned(12 downto 0));
  end component;

  -- component ports
  signal gamelogic_state       : gamelogic_state_t;
  signal clk25_i                 : std_logic := '0';
  signal ext_reset             : std_logic := '0';
  signal address_a_check       : unsigned(12 downto 0);
  signal check_read_data       : unsigned(11 downto 0);
  signal check_done            : std_logic := '0';
  signal keyboard              : unsigned(2 downto 0) := "001";
  signal crashed               : std_logic := '0';
  signal nochange              : std_logic := '0';
  signal current_direction_out : unsigned(2 downto 0);
  signal old_direction_out     : unsigned(2 downto 0);
  signal next_cell             : unsigned(12 downto 0);


begin  -- tb

  -- component instantiation
  DUT: check_logic
    port map (
      gamelogic_state       => gamelogic_state,
      clk25                 => clk25_i,
      ext_reset             => ext_reset,
      address_a_check       => address_a_check,
      check_read_data       => check_read_data,
      check_done            => check_done,
      keyboard              => keyboard,
      crashed               => crashed,
      nochange              => nochange,
      current_direction_out => current_direction_out,
      old_direction_out     => old_direction_out,
      next_cell             => next_cell);

  -- clock generation
  clk25_i <= not clk25_i after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here

       ext_reset <= '0';
       gamelogic_state <= CHECK;
       wait for 100 ns;
       ext_reset <= '1';
       wait for 100 ns;
       ext_reset <= '0';
       wait for 500 ns;
       keyboard <= "010";
       
       wait;
    
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration check_logic_tb_tb_cfg of check_logic_tb is
  for tb
  end for;
end check_logic_tb_tb_cfg;

-------------------------------------------------------------------------------
