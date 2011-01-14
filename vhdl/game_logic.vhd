--------------------------------------------------------------------------------
-- Module Name:    LOGIC - behavioral
--
-- Author: Aaron Storey
-- 
-- Description: This module controls the game logic for the snake physics etc.
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
use work.gamelogic_pkg.all;

entity game_logic is
  port(
    clk25         : in  std_logic;
    clk_slow      : in  std_logic;
    ext_reset     : in  std_logic;
    ram_WEA       : out std_logic             := '0';
    ram_EN        : out std_logic             := '1';
    ram_address_a : out unsigned(12 downto 0) := "0000000000000";
    ram_input_a   : out unsigned(11 downto 0) := "000000000000";
    ram_output_a  : in  unsigned(11 downto 0) := "000000000000";
    Direction     : in  unsigned(2 downto 0)
    );
end game_logic;

architecture Behavioral of game_logic is


  component ram_mux is
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
  end component;

  component score_logic is
    port(
      ext_reset       : in  std_logic;
      clk25           : in  std_logic;
      clk_slow        : in  std_logic;
      gamelogic_state : in  gamelogic_state_t;
      score_address   : out unsigned(12 downto 0);
      score_data      : out unsigned(11 downto 0);
      score_done      : out std_logic
      );
  end component;


  component tail_logic is
    port(
      gamelogic_state : in  gamelogic_state_t;
      clk_slow        : in  std_logic;
      ext_reset       : in  std_logic;
      address_a_tail  : out unsigned(12 downto 0);
      tail_read_data  : in  unsigned(11 downto 0);
      tail_write_data : out unsigned(11 downto 0);
      tailread_done   : out std_logic;
      tailwrite_done  : out std_logic;
      tail_done       : out std_logic
      );
  end component;

  component reset_logic is
    port(
      gamelogic_state  : in  gamelogic_state_t;
      clk25            : in  std_logic;
      ext_reset        : in  std_logic;
      address_a_reset  : out unsigned(12 downto 0);
      reset_write_data : out unsigned(11 downto 0);
      reset_done       : out std_logic;
      keyboard         : in  unsigned(2 downto 0)
      );
  end component;

  component corner_logic is
    port(
      ext_reset            : in  std_logic;
      clk_slow             : in  std_logic;
      gamelogic_state      : in  gamelogic_state_t;
      address_a_corner     : out unsigned(12 downto 0);
      corner_write_data    : out unsigned(11 downto 0);
      corner_done          : out std_logic;
      next_cell            : in  unsigned(12 downto 0);
      old_direction_in     : in  unsigned(2 downto 0);
      current_direction_in : in  unsigned(2 downto 0)
      );
  end component;

  component check_logic is
    port(
      gamelogic_state       : in  gamelogic_state_t;
      clk_slow              : in  std_logic;
      ext_reset             : in  std_logic;
      address_a_check       : out unsigned(12 downto 0);
      check_read_data       : in  unsigned(11 downto 0);
      check_done            : out std_logic;
      keyboard              : in  unsigned(2 downto 0);
      crashed               : out std_logic;
      nochange              : out std_logic;
      old_direction_out     : out unsigned(2 downto 0);
      current_direction_out : out unsigned(2 downto 0);
      next_cell             : out unsigned(12 downto 0);
      corner_cell           : out unsigned(12 downto 0)
      );
  end component;


  component head_logic is
    port(
      clk_slow        : in  std_logic;
      ext_reset       : in  std_logic;
      gamelogic_state : in  gamelogic_state_t;
      address_a_head  : out unsigned(12 downto 0);
      head_write_data : out unsigned(11 downto 0);
      head_done       : out std_logic;
      head_addr_done  : out std_logic;
      next_cell       : in  unsigned(12 downto 0);
      changed_dir     : in  std_logic
      );
  end component;

  signal tick                  : std_logic             := '0';
  signal nochange_int          : std_logic             := '0';
  signal check_done_int        : std_logic             := '0';
  signal reset_done_int        : std_logic             := '0';
  signal head_done_int         : std_logic             := '0';
  signal tailread_done_int     : std_logic             := '0';
  signal tailwrite_done_int    : std_logic             := '0';
  signal tail_done_int         : std_logic             := '0';
  signal score_done_int        : std_logic             := '0';
  signal crashed_int           : std_logic             := '0';
  signal corner_done_int       : std_logic             := '0';
  signal gamelogic_state       : gamelogic_state_t;
  signal head_write_data_int   : unsigned(11 downto 0) := (others => '0');
  signal head_cell_int         : unsigned(12 downto 0) := (others => '0');
  signal corner_write_data_int : unsigned(11 downto 0) := (others => '0');
  signal corner_cell_int       : unsigned(12 downto 0) := (others => '0');
  signal corner_cell_signal    : unsigned(12 downto 0) := (others => '0');
  signal tail_write_data_int   : unsigned(11 downto 0) := (others => '0');
  signal tail_read_data_int    : unsigned(11 downto 0) := (others => '0');
  signal tail_cell_int         : unsigned(12 downto 0) := (others => '0');
  signal score_data_int        : unsigned(11 downto 0) := (others => '0');
  signal score_address_int     : unsigned(12 downto 0) := (others => '0');
  signal reset_data_int        : unsigned(11 downto 0) := (others => '0');
  signal reset_cell_int        : unsigned(12 downto 0) := (others => '0');
  signal address_a_int         : unsigned(12 downto 0) := (others => '0');
  signal next_direction        : unsigned(2 downto 0)  := "001";
  signal check_cell_int        : unsigned(12 downto 0) := (others => '0');
  signal check_read_data_int   : unsigned(11 downto 0) := (others => '0');
  signal current_direction_int : unsigned(2 downto 0)  := (others => '0');
  signal old_direction_int     : unsigned(2 downto 0)  := (others => '0');
  signal next_cell_int         : unsigned(12 downto 0) := (others => '0');
  signal head_addr_done_int    : std_logic             := '0';
  signal changed_dir_int       : std_logic             := '0';


  
begin



  RAM_CNTRL : ram_mux
    port map (
      gamelogic_state   => gamelogic_state,
      WEA               => ram_WEA,
      address_a         => ram_address_a,
      input_a           => ram_input_a,
      output_a          => ram_output_a,
      head_write_data   => head_write_data_int,
      head_cell         => head_cell_int,
      corner_write_data => corner_write_data_int,
      corner_cell       => corner_cell_int,
      tail_write_data   => tail_write_data_int,
      tail_read_data    => tail_read_data_int,
      tail_cell         => tail_cell_int,
      score_write_data  => score_data_int,
      score_cell        => score_address_int,
      reset_data        => reset_data_int,
      reset_cell        => reset_cell_int,
      check_read_data   => check_read_data_int,
      check_cell        => check_cell_int);

  TAIL_CNTRL : tail_logic
    port map (
      gamelogic_state => gamelogic_state,
      clk_slow        => clk_slow,
      ext_reset       => ext_reset,
      address_a_tail  => tail_cell_int,
      tail_read_data  => tail_read_data_int,
      tail_write_data => tail_write_data_int,
      tailread_done   => tailread_done_int,
      tailwrite_done  => tailwrite_done_int,
      tail_done       => tail_done_int
      );

  SCORE_CNTRL : score_logic
    port map (
      ext_reset       => ext_reset,
      clk25           => clk25,
      clk_slow        => clk_slow,
      gamelogic_state => gamelogic_state,
      score_address   => score_address_int,
      score_data      => score_data_int,
      score_done      => score_done_int
      );


  CHECK_CNTRL : check_logic
    port map (
      gamelogic_state       => gamelogic_state,
      clk_slow              => clk_slow,
      ext_reset             => ext_reset,
      address_a_check       => check_cell_int,
      old_direction_out     => old_direction_int,
      check_read_data       => check_read_data_int,
      check_done            => check_done_int,
      nochange              => nochange_int,
      keyboard              => next_direction,
      crashed               => crashed_int,
      current_direction_out => current_direction_int,
      next_cell             => next_cell_int,
      corner_cell           => corner_cell_signal
      );

  CORNER_CNTRL : corner_logic
    port map (
      ext_reset            => ext_reset,
      clk_slow             => clk_slow,
      gamelogic_state      => gamelogic_state,
      address_a_corner     => corner_cell_int,
      corner_write_data    => corner_write_data_int,
      corner_done          => corner_done_int,
      next_cell            => corner_cell_signal,
      old_direction_in     => old_direction_int,
      current_direction_in => current_direction_int
      );

  RESET_CNTRL : reset_logic
    port map (
      gamelogic_state  => gamelogic_state,
      clk25            => clk25,
      ext_reset        => ext_reset,
      address_a_reset  => reset_cell_int,
      reset_write_data => reset_data_int,
      reset_done       => reset_done_int,
      keyboard         => next_direction
      );

  HEAD_CNTRL : head_logic
    port map (
      clk_slow        => clk_slow,
      ext_reset       => ext_reset,
      gamelogic_state => gamelogic_state,
      address_a_head  => head_cell_int,
      head_write_data => head_write_data_int,
      head_done       => head_done_int,
      head_addr_done  => head_addr_done_int,
      changed_dir     => nochange_int,
      next_cell       => next_cell_int);



  ram_EN <= '1';


-- purpose: controls the timer for the snake
-- type   : sequential
-- inputs : clk25, ext_reset
-- outputs: tick
  p_tick_timer : process (clk25, ext_reset)
    variable cnt : integer := 0;
  begin
    if (ext_reset = '1') then           --asynchronous reset (active high)
      tick <= '0';
      cnt  := 0;
    elsif clk25'event and clk25 = '1' then  --    rising clock edge   
      cnt := cnt + 1;
      if (cnt = 7500000) then
        tick <= '1';  --  move snake head every time the  timer reaches max.
        cnt  := 0;
      else
        tick <= '0';
      end if;
    end if;
  end process p_tick_timer;



-- purpose: controls which state the game logic is in
-- type   : sequential
-- inputs : clk25, ext_reset, tick, head_done, corner_done, corner, score, tail_done, crashed, reset_done
-- outputs: state
  p_state_machine : process (clk25, ext_reset)
  begin  -- process p_state_machine
    if ext_reset = '1' then                 -- asynchronous reset (active high)
      gamelogic_state <= IDLE;
    elsif clk25'event and clk25 = '1' then  -- rising clock edge
      case gamelogic_state is
        when IDLE =>
          if tick = '1' then
            gamelogic_state <= CHECK;
          end if;
        when CHECK =>
          if (check_done_int = '1') then
            gamelogic_state <= HEAD_DATA;
          elsif (nochange_int = '0') then
            gamelogic_state <= CORNER;
          elsif (crashed_int = '1') then
            gamelogic_state <= RESET;
          else
            gamelogic_state <= CHECK;
          end if;
        when HEAD_DATA =>
          if (head_addr_done_int = '1') then
            gamelogic_state <= HEAD_WRITE;
          end if;
        when HEAD_WRITE =>
          if (head_done_int = '1') then
            gamelogic_state <= IDLE;
          end if;
        when CORNER =>
          if (corner_done_int = '1') then
            gamelogic_state <= IDLE;
          end if;
        when TAIL_READ =>
          if (tailread_done_int = '1') then
            gamelogic_state <= TAIL_WRITE;
          elsif (tail_done_int = '1') then
            gamelogic_state <= SCORE;
          end if;
        when TAIL_WRITE =>
          if (tailwrite_done_int = '1') then
            gamelogic_state <= SCORE;
          end if;
        when SCORE =>
          if (score_done_int = '1') then
            gamelogic_state <= IDLE;
          end if;
        when RESET =>
          if (reset_done_int = '1') then
            gamelogic_state <= IDLE;
          end if;
      end case;
    end if;

  end process p_state_machine;



-- purpose: updates the user input from keyboard
-- type   : combinational
-- inputs : clk25, ext_reset, Direction, crashed
-- outputs: next_direction, reset_game
  p_keyboard_input : process (clk25, ext_reset)
  begin
    if (ext_reset = '1') then               --asynchronous reset (active high)
      next_direction <= "001";
    elsif clk25'event and clk25 = '1' then  --    rising clock edge   
-- update keyboard input      
      if (Direction /= "000") and (Direction /= "101") then
        next_direction <= Direction;
      elsif (Direction = "101") and (crashed_int = '1') then
        next_direction <= "111";
      end if;
    end if;
-- end of keyboard update
  end process p_keyboard_input;




end Behavioral;

