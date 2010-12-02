--------------------------------------------------------------------------------
-- Module Name:    MAINBOARD - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module connects all the components together as a system
--              
-- 
-- 
-- Dependencies: VRAM, DCM, LOGIC, VGA, CHROM1 & SHFTREG
-- 
-- 
-- Assisted by:
--
-- Anthonix the great.
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity MAINBOARD is
  port(ext_clk_50  : in  std_logic;
       ext_reset   : in  std_logic;
       clks_locked : out std_logic;
		 red_out     : out std_logic;
       green_out   : out std_logic;
       blue_out    : out std_logic;
       hs_out      : out std_logic;
       vs_out      : out std_logic;
		 ps2d : in std_logic;
		 ps2c : in std_logic
		 );
end MAINBOARD;

architecture behavioral of MAINBOARD is

component KeyboardController is
    Port ( Clock : in STD_LOGIC;
	        KeyboardClock : in  STD_LOGIC;
           KeyboardData : in  STD_LOGIC;
           Direction : out std_logic_vector(1 downto 0)
	);
end component;

  component clock_sync is port (
			 CLKIN_IN        : in    std_logic; 
          RST_IN          : in    std_logic; 
          CLK_25_0        : out   std_logic; 
          CLK_50_0        : out   std_logic; 
          LOCKED_OUT      : out   std_logic
    );
  end component;
  
  component game_logic is
  port( 
		 clk25 : in std_logic;
       ext_reset   : in  std_logic;
       WEA_int     : out std_logic;
       EN_int      : out std_logic;
       address_a_int : out std_logic_vector(12 downto 0);
	    input_a_int   : out unsigned(15 downto 0);
       output_a_int   : in unsigned(15 downto 0);
		 colour : out unsigned(1 downto 0);
		 Direction : in std_logic_vector(1 downto 0)
				
		 );
end component;

component vga_core is
  port( 
		 clk25  : in  std_logic;
       ext_reset   : in  std_logic;
       red_out     : out std_logic;
       green_out   : out std_logic;
       blue_out    : out std_logic;
       hs_out      : out std_logic;
       vs_out      : out std_logic;
		 ram_address_b : out unsigned(12 downto 0);
		 ram_data_b : in unsigned(15 downto 0);
		 rom_address : out unsigned(8 downto 0);
		 rom_data : in unsigned(7 downto 0);
		 strobe: out std_logic;
		 row_data : out unsigned(7 downto 0);
		 pixel : in std_logic;
		 colour_in : in unsigned(1 downto 0)
		 );
end component;

component screen_ram is
    port (clk50  : in std_logic;
          write_enable_a   : in std_logic;
          enable_a   : in std_logic;
          addr_a : in std_logic_vector(12 downto 0);
			 addr_b : in unsigned(12 downto 0);
          data_input_a   : in unsigned(15 downto 0);
          data_output_a   : out unsigned(15 downto 0);
			 data_output_b   : out unsigned(15 downto 0)
			 );
end component;

   component fontrom is port (
	 clk25 : in std_logic;
    address : in  unsigned( 8 downto 0 );
    data    : out unsigned( 7 downto 0 )
    );
  end component;
  
    component serializer is
  port (
    clk : in  std_logic;
    din          : in  unsigned(7 downto 0);
    strobe       : in  std_logic;
    dout         : out std_logic
    );
end component;


  signal clk25        : std_logic;
  signal clk50			  : std_logic;
  signal reset_n : std_logic;
  signal WEA : std_logic;
  signal EN : std_logic;
  signal         address_a : std_logic_vector(12 downto 0);
	signal		 address_b : unsigned(12 downto 0);
        signal  data_i_a  : unsigned(15 downto 0);
         signal data_o_a : unsigned(15 downto 0);
			 signal data_o_b : unsigned(15 downto 0);
			   signal number_data    : unsigned( 7 downto 0);
  signal number_address : unsigned( 8 downto 0);
  signal strobe_sig : std_logic;
  signal dout_int : std_logic;
  signal din_int : unsigned(7 downto 0);
  signal colour_int : unsigned(1 downto 0);
  signal Direction_int : std_logic_vector(1 downto 0);
 -- signal kb_data : std_logic;
 



begin
  
  -- PS2  Keyboard Controller instantiation


 PS2 : KeyboardController port map (
			  Clock => clk25,
	        KeyboardClock => ps2c,
           KeyboardData => ps2d,
           Direction => Direction_int
	);


  -- Clock Manager instantiation 
  DCM : clock_sync port map (
			 CLKIN_IN => ext_clk_50,
			 RST_IN => ext_reset,
          CLK_25_0 => clk25,
          CLK_50_0 => clk50,
			 LOCKED_OUT => clks_locked
    );


--  GAME LOGIC instantiation
  LOGIC: game_logic
    port map (
        clk25         => clk25,
        ext_reset     => ext_reset,
        WEA_int       => WEA,
        EN_int        => EN,
        address_a_int => address_a,
        input_a_int   => data_i_a,
        output_a_int  => data_o_a,
		  colour => colour_int,
		  Direction => Direction_int
		
		  );



  -- VGA Core instantiation 
  VGA : vga_core port map (
		 clk25  => clk25,
       ext_reset   => ext_reset,
       red_out     => red_out,
       green_out   => green_out,
       blue_out    => blue_out,
       hs_out      => hs_out,
       vs_out      => vs_out,
		 ram_address_b => address_b,
		 ram_data_b => data_o_b,
		 rom_address => number_address,
		 rom_data => number_data,
		 strobe => strobe_sig,
		 row_data => din_int,
		 pixel => dout_int,
		 colour_in => colour_int
    );
	 
 -- VRAM instantiation
  VRAM: screen_ram
    port map (
        clk50          => clk50,
        write_enable_a => WEA,
        enable_a       => EN,
        addr_a         => address_a,
        addr_b         => address_b,
        data_input_a   => data_i_a,
        data_output_a  => data_o_a,
        data_output_b  => data_o_b);

  -- Character generator memory instantiation
  CHROM : fontrom port map (
	 clk25 => clk25,
	 address => number_address,
    data    => number_data
    );

-- Serializer instantiation	 
	 SHFTREG : serializer port map (
    clk => clk25,
	 din          => din_int,
    strobe       => strobe_sig,
    dout         => dout_int
    );

end behavioral;

