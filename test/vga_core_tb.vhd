-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity vga_core_tb is

end vga_core_tb;

-------------------------------------------------------------------------------

architecture tb of vga_core_tb is

  component vga_core
    port (
      clk25         : in  std_logic;
      ext_reset     : in  std_logic;
      red_out       : out std_logic;
      green_out     : out std_logic;
      blue_out      : out std_logic;
      hs_out        : out std_logic;
      vs_out        : out std_logic;
      ram_address_b : out unsigned(12 downto 0);
      ram_data_b    : in  unsigned(15 downto 0);
      rom_address   : out unsigned(8 downto 0);
      rom_data      : in  unsigned(7 downto 0);
      strobe        : out std_logic;
      row_data      : out unsigned(7 downto 0);
      pixel         : in  std_logic);
  end component;

  signal clk25_i         : std_logic := '0';
  signal ext_reset_i     : std_logic := '0';
  signal red_out_i       : std_logic;
  signal green_out_i     : std_logic;
  signal blue_out_i      : std_logic;
  signal hs_out_i        : std_logic;
  signal vs_out_i        : std_logic;
  signal ram_address_b_i : unsigned(12 downto 0);
  signal ram_data_b_i    : unsigned(15 downto 0);
  signal rom_address_i   : unsigned(8 downto 0);
  signal rom_data_i      : unsigned(7 downto 0);
  signal strobe_i        : std_logic;
  signal row_data_i      : unsigned(7 downto 0);
  signal pixel_i         : std_logic;


begin  -- tb

  DUT: vga_core
    port map (
        clk25         => clk25_i,
        ext_reset     => ext_reset_i,
        red_out       => red_out_i,
        green_out     => green_out_i,
        blue_out      => blue_out_i,
        hs_out        => hs_out_i,
        vs_out        => vs_out_i,
        ram_address_b => ram_address_b_i,
        ram_data_b    => ram_data_b_i,
        rom_address   => rom_address_i,
        rom_data      => rom_data_i,
        strobe        => strobe_i,
        row_data      => row_data_i,
        pixel         => pixel_i);
		  
		  clk25_i <= not clk25_i after 10 ns;
		
		  
		  p_test : process
		  begin
		  ext_reset_i <= '0';
		  wait for 100 ns;
		  ext_reset_i <= '1';
		  wait for 100 ns;
		  ext_reset_i <= '0';
		  report "simulation finished" severity note;
	  wait;
		  
end process p_test;
  

end tb;

-------------------------------------------------------------------------------
