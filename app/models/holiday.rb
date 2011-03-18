class Holiday < ActiveRecord::Base
  belongs_to :user

  def self.new_holiday(name, day, month)
    @holiday = Holiday.new
    @holiday.day = day
    @holiday.month = month
    @holiday.name = name
    @holiday
  end

  def self.dynamic_holidays(year)
    @list = dynamics(year)

    @holidays = Array.new

    @pascoa = @list[0]
    @carnaval = @list[1]
    @corpus = @list[2]

    @holidays << new_holiday(I18n.t('holiday.dynamic.easter'), @pascoa.day, @pascoa.month)
    @holidays << new_holiday(I18n.t('holiday.dynamic.carnival'), @carnaval.day, @carnaval.month)
    @holidays << new_holiday(I18n.t('holiday.dynamic.corpus'), @corpus.day, @corpus.month)

    @holidays
  end

  def self.dynamics(year)
    @holidays = Array.new

    @x = 24
    @y = 5
    if year >= 2100 && year <= 2199
      @y = 6
    elsif year >= 2200 && year <= 2299
      @x = 25
      @y = 7
    end

    @a = year % 19
    @b = year % 4
    @c = year % 7
    @d = (19 * @a + @x) % 30
    @e = (2 * @b + 4 * @c + 6 * @d + @y) % 7

    if (@d + @e) > 9
      @day = @d + @e -9
      @month = 4
    else
      @day = @d + @e + 22
      @month = 3
    end

    if @month == 4 && @day == 26
      @day = 19
    end

    if @month == 4 && @day == 25 && @d == 28 && @a > 10
      @day = 18
    end

    @pascoa = Date.new(year, @month, @day)
    @carnaval = @pascoa - 47.days
    @corpus = @pascoa + 60.days

    @holidays << @pascoa
    @holidays << @carnaval
    @holidays << @corpus

    @holidays
  end

  def self.all_holidays(year)
    @holidays = dynamic_holidays(year)

    @list = find(:all)

    @holidays.concat(@list)
  end

  def self.holiday?(year, month, day)
    @holidays ||= all_holidays(year)

    @return = ""
    @holidays.each do |holiday|
      if holiday.day == day && holiday.month == month
        @return = holiday.name and break
      end
    end

    @return
  end
end
