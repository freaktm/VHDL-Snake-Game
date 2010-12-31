library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity keyboard_stim_gen is
  
  port (
    clk, reset_n      : in  std_logic;
    data_in           : in  std_logic_vector(7 downto 0);
    wr_en             : in  std_logic;
    ready             : out std_logic;
    data_out, clk_out : out std_logic

    );

end keyboard_stim_gen;

architecture rtl of keyboard_stim_gen is


  type state_t is (IDLE, TRANSMITTING, PARITY, STOPBIT, STARTBIT);
  signal state : state_t;
  
  signal counter : unsigned(5 downto 0);

  signal data_int : std_logic_vector(7 downto 0);
  
begin  -- rtl

  data_out <= data_int(0);
  clk_out <= not counter(2);

  with state select
    ready <=
    '1' when IDLE,
    '0' when others;
  
  p_regs : process (clk, reset_n)
  begin  -- process p_counter
    if reset_n = '0' then               -- asynchronous reset (active low)
      counter <= (others => '0');
      data_int <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if state = IDLE then
        counter <= (others => '0');
      else
        counter <= counter + to_unsigned(1, counter'length);
      end if;

      if state=IDLE and wr_en='1' then
        data_int <= data_in;
      elsif state=TRANSMITTING and counter(2 downto 0)="111" then
        data_int <= '0' & data_int(7 downto 1);
      end if;
    end if;
  end process p_regs;

  p_fsm : process (clk, reset_n)
  begin  -- process p_fsm
    if reset_n = '0' then               -- asynchronous reset (active low)
      state <= IDLE;

    elsif clk'event and clk = '1' then  -- rising clock edge
      if state = IDLE and wr_en = '1' then
        state    <= STARTBIT;
 
      elsif state=TRANSMITTING and counter="111111" then
        state <= PARITY;
      elsif state=PARITY and counter(2 downto 0)="111" then
        state <= STOPBIT;
      elsif state=STOPBIT and counter(2 downto 0)="111" then
        state <= IDLE;
      elsif state=STARTBIT and counter(2 downto 0)="111" then
        state <= TRANSMITTING;
      end if;
     
    end if;
  end process p_fsm;

end rtl;
