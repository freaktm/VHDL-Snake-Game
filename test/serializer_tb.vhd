-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity serializer_tb is

end serializer_tb;

-------------------------------------------------------------------------------

architecture tb of serializer_tb is

  component serializer
    port (
      clk, reset_n : in  std_logic;
      din          : in  std_logic_vector(7 downto 0);
      strobe       : in  std_logic;
      dout         : out std_logic);
  end component;

  signal clk, reset_n : std_logic := '1';
  signal din_i        : std_logic_vector(7 downto 0);
  signal strobe_i     : std_logic;
  signal dout_i       : std_logic;

begin  -- tb

  DUT : serializer
    port map (
      clk     => clk,
      reset_n => reset_n,
      din     => din_i,
      strobe  => strobe_i,
      dout    => dout_i);

  clk <= not clk after 10 ns;

  p_test : process
  begin  -- process p_test
    strobe_i <= '0';
    din_i    <= (others => '0');
    wait for 100 ns;
    reset_n  <= '0';
    wait for 100 ns;
    reset_n  <= '1';

    wait for 100 ns;
    wait until clk'event and clk = '1';
    strobe_i <= '1';
    din_i    <= X"55";

    for i in 0 to 7 loop
      wait until clk'event and clk = '1';
      strobe_i <= '0';
      
    end loop;  -- i

    strobe_i <= '1';
    din_i    <= X"18";

    for i in 0 to 7 loop
      wait until clk'event and clk = '1';
      strobe_i <= '0';
    end loop;  -- i

    strobe_i <= '1';
    din_i    <= X"AA";

    for i in 0 to 7 loop
      wait until clk'event and clk = '1';
      strobe_i <= '0';
    end loop;  -- i

    report "simulation finished" severity note;
    wait;


  end process p_test;


end tb;

-------------------------------------------------------------------------------
