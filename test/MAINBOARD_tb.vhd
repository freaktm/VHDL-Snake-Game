-------------------------------------------------------------------------------
-- Title      : Testbench for design "MAINBOARD"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : MAINBOARD_tb.vhd
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

-------------------------------------------------------------------------------

entity MAINBOARD_tb is

end MAINBOARD_tb;

-------------------------------------------------------------------------------

architecture tb of MAINBOARD_tb is

  component MAINBOARD
    port (
      ext_clk_50  : in  std_logic;
      ext_reset   : in  std_logic;
      clks_locked : out std_logic;
      red_out     : out std_logic;
      green_out   : out std_logic;
      blue_out    : out std_logic;
      hs_out      : out std_logic;
      vs_out      : out std_logic;
      ps2d        : in  std_logic;
      ps2c        : in  std_logic);
  end component;

  -- component ports
  signal ext_clk_50_i  : std_logic;
  signal ext_reset_i   : std_logic;
  signal clks_locked_i : std_logic;
  signal red_out_i     : std_logic;
  signal green_out_i   : std_logic;
  signal blue_out_i    : std_logic;
  signal hs_out_i      : std_logic;
  signal vs_out_i      : std_logic;
  signal ps2d_i        : std_logic;
  signal ps2c_i        : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT: MAINBOARD
    port map (
      ext_clk_50  => ext_clk_50_i,
      ext_reset   => ext_reset_i,
      clks_locked => clks_locked_i,
      red_out     => red_out_i,
      green_out   => green_out_i,
      blue_out    => blue_out_i,
      hs_out      => hs_out_i,
      vs_out      => vs_out_i,
      ps2d        => ps2d_i,
      ps2c        => ps2c_i);

  -- clock generation
  ext_clk_50_i <= not ext_clk_50_i after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
   
    ext_reset_i <= '0';
    wait for 100 ns;
    ext_reset_i <= '1';
    wait for 100 ns;
    ext_reset_i <= '0';
    wait;

    
  end process WaveGen_Proc;


end tb;


