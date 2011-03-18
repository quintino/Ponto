class PointsController < ApplicationController
  def getdate
    @point = Point.new
    @point.next_time = 7

    respond_to do |format|
      format.html
      format.xml  { render :xml => @point }
    end
  end

  def selectdate
    begin
      @point = Point.new(params[:point])
      @aux = current_user.points.find_by_date_record(@point.date_record)

      if @aux.nil?
        @point.morning_enter = Time.local(@point.date_record.year, @point.date_record.month, @point.date_record.day)
        @point.afternoon_enter = @point.morning_enter
        @point.overnight_enter = @point.morning_enter
        @point.morning_exit = @point.morning_enter
        @point.afternoon_exit = @point.morning_enter
        @point.overnight_exit = @point.morning_enter
      else
        @point = @aux
      end

      respond_to do |format|
        format.html
        format.xml  { render :xml => @point }
      end
    rescue NoMethodError => e
      respond_to do |format|
        format.html { redirect_to(:getdate) }
      end
    end
  end

  def create
    @point = Point.new(params[:point])
    @point.user = current_user

    respond_to do |format|
      if @point.save
        format.html { redirect_to(root_url, :notice => t('point.message.manual', :name => t('point.message.saved'))) }
        format.xml  { render :xml => @point, :status => :created, :location => @point }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @point.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @point = current_user.points.find(params[:id])

    respond_to do |format|
      if @point.update_attributes(params[:point])
        format.html { redirect_to(root_url, :notice => t('point.message.manual', :name => t('point.message.updated'))) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @point.errors, :status => :unprocessable_entity }
      end
    end
  end

  def register
    @point = Point.new
    @point.date_record = Time.new.to_date
    @aux = current_user.points.find_by_date_record(@point.date_record)

    if @aux.nil?
      @point.next_time = 1
      @point.user = current_user
    else
      @point = @aux
      if @point.next_time.nil?
        @point.next_time = 1
      else
        @point.next_time = @point.next_time + 1.to_int
      end
    end

    if @point.next_time > 6
      respond_to do |format|
        format.html { redirect_to(root_url, :notice => t('point.message.blocked')) }
      end and return
    end

    @local = Time.now
    case @point.next_time
      when 1 then
        @point.morning_enter = @local
        @timer = t('point.attribute.enter', :name => t('point.attribute.morning'))
      when 2 then
        @point.morning_exit = @local
        @timer = t('point.attribute.exit', :name => t('point.attribute.morning'))
      when 3 then
        @point.afternoon_enter = @local
        @timer = t('point.attribute.enter', :name => t('point.attribute.afternoon'))
      when 4 then
        @point.afternoon_exit = @local
        @timer = t('point.attribute.exit', :name => t('point.attribute.afternoon'))
      when 5 then
        @point.overnight_enter = @local
        @timer = t('point.attribute.enter', :name => t('point.attribute.overnight'))
      when 6 then
        @point.overnight_exit = @local
        @timer = t('point.attribute.exit', :name => t('point.attribute.overnight'))
    end

    if @point.next_time == 1
      @point.save
    else
      @point.update_attributes(@point.attributes)
    end

    @msg = t('point.message.date', :date => @point.date_record.strftime('%d/%m/%Y'))
    @msg = @msg + ' - '
    @msg = @msg + t('point.message.time', :name => @timer, :time => @local.strftime('%H:%M'))

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => @msg) }
      format.xml  { render :xml => @point }
    end
  end

  def getmonth
    @point = Point.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @point }
    end
  end

  def exists(list, year, month, day)
    @return = nil

    list.each do |item|
      if item.date_record.day == day && item.date_record.month == month && item.date_record.year == year
        @return = item
        break
      end
    end

    @return
  end

  def selectmonth
    begin
      @point = Point.new(params[:point])
      @end_date = (@point.date_record + 1.month) - 1.day
      @points = current_user.points.find(:all, :conditions => ['date_record BETWEEN ? AND ?', @point.date_record, @end_date])

      if !current_user.daily_hour.nil?
        @points.each do |point|
          @total = get_total(point)

          @hours = @total / 3600
          @minutes = (@total / 60) - (@hours * 60)

          @daily = Time.parse(@hours.to_s << ':' << @minutes.to_s << ':00')
          @aux = Time.parse(current_user.daily_hour.to_s.split('T', 2)[1].split('+',2)[0])
          @total = @aux - @daily

          point.positive = true
          if @total < 0
            point.positive = false
            @total = @total * -1
          end

          @hours = @total / 3600

          if @hours < 1
            @minutes = (@hours * 60).to_i
            @hours = 0
          else
            @hours = @hours.to_i
            @minutes = ((@total / 60) - (@hours * 60)).to_i
          end

          point.left = Time.parse(@hours.to_s << ':' << @minutes.to_s << ':00')
        end
      end

      @newlist = Array.new

      for i in 1..@end_date.day
        @item = exists(@points, @end_date.year, @end_date.month, i)
        if @item.nil?
          @aux = Point.new
          @aux.date_record = Date.new(@end_date.year, @end_date.month, i)
        else
          @aux = @item
        end
        @newlist << @aux
      end

      @points = @newlist

      @points.each do |point|
        point.holiday = Holiday.holiday?(point.date_record.year, point.date_record.month, point.date_record.day)
        point.manual = ''
        if !point.next_time.nil? && point.next_time > 6
          point.manual = t('point.label.manual')
        end
      end

      respond_to do |format|
        format.html
        format.xml  { render :xml => @point }
      end
    rescue NoMethodError => e
      respond_to do |format|
        format.html { redirect_to(:getmonth) }
      end
    end
  end

  def getyear
    @point = Point.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @point }
    end
  end

  def workdays(year, month)
    @start = Date.new(year, month, 1)
    @end = (@start + 1.month) - 1.day

    @total = 0
    for i in @start.day..@end.day
      @date = Date.new(year, month, i)
      if @date.strftime('%w').to_i > 0 && @date.strftime('%w').to_i < 6
        @name = Holiday.holiday?(year, month, i)
        if @name.to_s.empty?
          @total = @total + 1
        end
      end
    end

    @total
  end

  def selectyear
    begin
      @point = Point.new(params[:point])
      @start = Date.new(@point.date_record.strftime('%Y').to_i, 1, 1)
      @end = Date.new(@point.date_record.strftime('%Y').to_i, 12, 31)
      @points = current_user.points.find(:all, :conditions => ['date_record BETWEEN ? AND ?', @start, @end])

      @aux = (current_user.daily_hour.nil? ? nil : Time.parse(current_user.daily_hour.to_s.split('T', 2)[1].split('+',2)[0]))
      @months = Array.new(12)
      for i in 0..11 do
        @months[i] = Point.new
        @months[i].month = i + 1
        @months[i].hours = 0
        @months[i].minutes = 0
        @works = workdays(@point.date_record.strftime('%Y').to_i, i + 1)
        @hours = (@aux.nil? ? 0 : @hours = @aux.hour * @works)
        @months[i].work_days = @works
        @months[i].hour_days = @hours
        @months[i].positive = true
        @months[i].diff = ''
      end

      @points.each do |aux|
        @month = @months[aux.date_record.month - 1]
        @total = get_total(aux)
        @hours = @total / 3600
        @minutes = (@total / 60) - (@hours * 60)
        @month.hours = @month.hours + @hours
        @month.minutes = @month.minutes + @minutes
      end

      @months.each do |month|
        if month.minutes > 59
          @aux = month.minutes / 60
          month.minutes = month.minutes % 60
          month.hours = month.hours + @aux
        end
        @aux_hour = month.hour_days
        @aux_minute = 0
        if month.minutes > 0
          @aux_hour = @aux_hour - 1
          @aux_minute = 60 - month.minutes
        end
        @aux_hour = @aux_hour - month.hours
        if @aux_hour < 0
          month.positive = false
          @aux_hour = @aux_hour * -1
        end
        month.diff = @aux_hour.to_s << ':' << (@aux_minute < 10 ? '0' : '') << @aux_minute.to_s
      end

      respond_to do |format|
        format.html
        format.xml  { render :xml => @point }
      end
    rescue NoMethodError => e
      respond_to do |format|
        format.html { redirect_to(:getyear) }
      end
    end
  end

  def get_total(obj)
    if obj.next_time > 1
      @manha = obj.morning_exit.to_i - obj.morning_enter.to_i
      @manha = @manha > 0 ? @manha : 0
    else
      @manha = 0
    end
    if obj.next_time > 3
      @tarde = obj.afternoon_exit.to_i - obj.afternoon_enter.to_i
      @tarde = @tarde > 0 ? @tarde : 0
    else
      @tarde = 0
    end
    if obj.next_time > 5
      @noite = obj.overnight_exit.to_i - obj.overnight_enter.to_i
      @noite = @noite > 0 ? @noite : 0
    else
      @noite = 0
    end
    @manha + @tarde + @noite
  end
end