library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gamelogic is

  generic (
    DATA_WIDTH : integer := 16);
  port (
    clk, reset_n : in std_logic;

    wr_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
    wr_en   : out std_logic;
    addr    : out integer;
    rd_data : in  std_logic_vector(DATA_WIDTH-1 downto 0)


    );

end gamelogic;

architecture rtl of gamelogic is

  component head_unit
    generic (
      DATA_WIDTH : integer);
    port (
      clk, reset_n : in  std_logic;
      wr_data      : out std_logic_vector(DATA_WIDTH-1 downto 0);
      wr_en        : out std_logic;
      addr         : out integer;
      rd_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0)

      );
  end component;

  component tail_unit
    generic (
      DATA_WIDTH : integer);
    port (
      clk, reset_n : in  std_logic;
      wr_data      : out std_logic_vector(DATA_WIDTH-1 downto 0);
      wr_en        : out std_logic;
      addr         : out integer;
      rd_data      : in  std_logic_vector(DATA_WIDTH-1 downto 0)

      );
  end component;


  type ram_bus_t is record
    wr_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    wr_en   : std_logic;
    addr    : integer;
    rd_data : std_logic_vector(DATA_WIDTH-1 downto 0);
  end record;

  type state_t is (IDLE, HEAD, TAIL);

  signal state : state_t;

  signal ram_bus, head_ram_bus, tail_ram_bus : ram_bus_t;
  
begin

  head_unit_1: head_unit
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      clk     => clk,
      reset_n => reset_n,
      wr_data => head_ram_bus.wr_data,
      wr_en   => head_ram_bus.wr_en,
      addr    => head_ram_bus.addr,
      rd_data => head_ram_bus.rd_data
      );

  tail_unit_1: tail_unit
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      clk     => clk,
      reset_n => reset_n,
      wr_data => tail_ram_bus.wr_data,
      wr_en   => tail_ram_bus.wr_en,
      addr    => tail_ram_bus.addr,
      rd_data => tail_ram_bus.rd_data);
  
  wr_data         <= ram_bus.wr_data;
  wr_en           <= ram_bus.wr_en;
  addr            <= ram_bus.addr;
  ram_bus.rd_data <= rd_data;


  p_next_state : process (clk, reset_n)
  begin  -- process p_next_state
    if reset_n = '0' then               -- asynchronous reset (active low)
      state <= IDLE;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when IDLE =>
          if tick = '1' then
            state <= HEAD;
          end if;
        when HEAD =>
          if head_done = '1' then
            state <= TAIL;
          end if;
        when TAIL =>
          if tail_done = '1' then
            state <= IDLE;
          end if;
        when others =>
          state <= IDLE;
      end case;
    end if;
  end process p_next_state;

  p_sel : process (state)
  begin  -- process p_sel
    if state = HEAD then
      sel <= '0';
    else
      sel <= '1';
    end if;
  end process p_sel;

  p_head_en : process (state)
  begin  -- process p_head_en
    if state = HEAD then
      head_en <= '1';
    else
      head_en <= '0';
    end if;
  end process p_head_en;

  p_head_en : process (state)
  begin  -- process p_head_en
    if state = TAIL then
      tail_en <= '1';
    else
      tail_en <= '0';
    end if;
  end process p_head_en;



  p_mux : process (state, head_ram_bus, tail_ram_bus)
  begin  -- process p_mux
    if state = HEAD then
      ram_bus <= head_ram_bus;
    else
      ram_bus <= tail_ram_bus;
    end if;
  end process p_mux;
  
end rtl;
