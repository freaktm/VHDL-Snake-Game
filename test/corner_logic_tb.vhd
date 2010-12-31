-------------------------------------------------------------------------------
-- Title      : Testbench for design "corner_logic"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : corner_logic_tb.vhd
-- Author     : Aaron Storey  <freaktm@freaktm>
-- Company    : 
-- Created    : 2011-01-01
-- Last update: 2011-01-01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-01  1.0      freaktm	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gamelogic_pkg.all;


-------------------------------------------------------------------------------

entity corner_logic_tb is

end corner_logic_tb;

-------------------------------------------------------------------------------

architecture tb of corner_logic_tb is

  component corner_logic
    port (
      ext_reset            : in  std_logic;
      clk_slow             : in  std_logic;
      gamelogic_state      : in  gamelogic_state_t;
      address_a_corner     : out unsigned(12 downto 0);
      corner_write_data    : out unsigned(11 downto 0);
      corner_done          : out std_logic;
      next_cell            : in  unsigned(12 downto 0);
      old_direction_in     : in  unsigned(2 downto 0);
      current_direction_in : in  unsigned(2 downto 0));
  end component;

  -- component ports
  signal ext_reset            : std_logic;
  signal clk_slow             : std_logic;
  signal gamelogic_state      : gamelogic_state_t;
  signal address_a_corner     : unsigned(12 downto 0);
  signal corner_write_data    : unsigned(11 downto 0);
  signal corner_done          : std_logic;
  signal next_cell            : unsigned(12 downto 0);
  signal old_direction_in     : unsigned(2 downto 0);
  signal current_direction_in : unsigned(2 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT: corner_logic
    port map (
      ext_reset            => ext_reset,
      clk_slow             => clk_slow,
      gamelogic_state      => gamelogic_state,
      address_a_corner     => address_a_corner,
      corner_write_data    => corner_write_data,
      corner_done          => corner_done,
      next_cell            => next_cell,
      old_direction_in     => old_direction_in,
      current_direction_in => current_direction_in);

  -- clock generation
  clk_slow <= not clk_slow after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
   wait for 100 ns;
   ext_reset <= '1';
   wait for 100 ns;
   ext_reset <= '0';


   wait;
   
 
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration corner_logic_tb_tb_cfg of corner_logic_tb is
  for tb
  end for;
end corner_logic_tb_tb_cfg;

-------------------------------------------------------------------------------
