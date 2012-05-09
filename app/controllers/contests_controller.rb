class ContestsController < ApplicationController
  before_filter :admin_filter, only: ['new','edit', 'create', 'update']
  # GET /contests
  def index
    # 開催期間に当てはまるコンテストだけ表示する
    @contests = Contest.all.select{|c| c.start_time <= Time.now && Time.now <= c.end_time}
  end

  # GET /contests/1
  def show
    @contest = Contest.find(params[:id])
  end

  # GET /contests/new
  def new
    @contest = Contest.new
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
  end

  # POST /contests
  def create
    # 作り方がわからないので無理やり
    s = DateTime.new(
      *((1..5).map{|i| params[:contest]["start_time(#{i}i)".to_sym].to_i}),
      0,
      0.375
    )
    e = DateTime.new(
      *((1..5).map{|i| params[:contest]["end_time(#{i}i)".to_sym].to_i}),
      0,
      0.375
    )
    params[:contest][:start_time] = s
    params[:contest][:end_time] = e

    @contest = Contest.new(params[:contest])
    if @contest.save
      redirect_to @contest, notice: 'Contest was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /contests/1
  def update
    @contest = Contest.find(params[:id])

    if @contest.update_attributes(params[:contest])
      redirect_to @contest, notice: 'Contest was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /contests/1
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy

    redirect_to contests_url
  end
end
