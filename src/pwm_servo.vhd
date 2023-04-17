library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;

entity pwm_servo is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        servo : out std_logic
    );
end entity;

architecture Behavior of pwm_servo is

    component pwm_enhanced is
        generic (
            R : integer := 8
        );
        port (
            clk     : in std_logic;
            reset   : in std_logic;
            dvsr    : in std_logic_vector (31 downto 0);
            duty    : in std_logic_vector (R downto 0);
            pwm_out : out std_logic);
    end component;

    constant resolution : integer                        := 8;
    constant dvsr       : std_logic_vector (31 downto 0) := std_logic_vector(to_unsigned(4882, 32));

    signal counter  : integer;
    signal clk_50Hz : std_logic;
    --constant clk_50Hz_half_cp : integer := 1_250_000; -- 125_000_000 / (50Hz * 2)
    constant sine_thresh : integer := 2_500_000; -- 125_000_000 / (50Hz) = 2_500_000
    signal duty_sine     : std_logic_vector (resolution downto 0);
    signal pwm_sine_reg  : std_logic;

    -- ROM containing sine values
    signal addr : unsigned(resolution - 1 downto 0);
    subtype addr_range is integer range 0 to 2 ** resolution - 1;

    type rom_type is array (addr_range) of unsigned(resolution - 1 downto 0);

    function init_rom return rom_type is
        variable rom_v      : rom_type;
        variable angle      : real;
        variable sin_scaled : real;
    begin

        for i in addr_range loop
            angle      := real(i) * ((2.0 * MATH_PI) / 2.0 ** resolution);
            sin_scaled := (1.0 + sin(angle)) * (2.0 ** resolution - 1.0) / 2.0;
            rom_v(i)   := to_unsigned(integer(round(sin_scaled)), resolution);
        end loop;
        return rom_v;
    end init_rom;

    constant rom     : rom_type := init_rom;
    signal sine_data : unsigned(resolution - 1 downto 0);

begin

    pwm2 : pwm_enhanced
    generic map(R => resolution)
    port map(
        clk => clk, reset => reset, dvsr => dvsr,
        duty => duty_sine, pwm_out => pwm_sine_reg);

    -- Sine Threshold Pulse Counter
    process (clk, reset)
    begin
        if reset = '1' then
            counter  <= 0;
            clk_50Hz <= '0';
        elsif rising_edge(clk) then
            if counter < sine_thresh then
                counter  <= counter + 1;
                clk_50Hz <= '0';
            else
                counter  <= 0;
                clk_50Hz <= '1';
            end if;
        end if;
    end process;

    process (clk, reset)
    begin
        if reset = '1' then
            duty_sine <= (others => '0');
            addr      <= (others => '0');
        elsif rising_edge(clk) then
            if clk_50Hz = '1' then
                if unsigned(duty_sine) <= 2 ** resolution then
                    addr                   <= unsigned(addr) + 1;
                    sine_data              <= rom(to_integer(addr));
                    duty_sine              <= '0' & std_logic_vector(unsigned(sine_data));
                else
                    duty_sine <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    servo <= pwm_sine_reg;
end Behavior;