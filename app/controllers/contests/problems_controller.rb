class Contests::ProblemsController < AuthController
  before_filter :load_contest
  private
  def load_contest
    @contest = Contest.find(params[:contest_id])
    @score = @current_user.scores
      .where(contest_id: @contest.id)
      .first
    unless @score
      @score = Score.new(contest_id: @contest.id, user: @current_user)
      @score.save
    end
  end

  public
  # GET /contests/1/problems
  # GET /contests/1/problems.json
  def index
    @problems = @contest.problems
    @users = User.where(is_admin: false, 'scores.contest_id' => @contest.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @problems }
    end
  end

  # GET /contests/1/problems/1
  # GET /contests/1/problems/1.json
  def show
    @problem = Problem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @problem }
    end
  end

  # POST /contests/1/problems/1/submit
  def submit
    problem = Problem.find(params[:id])
    output = params[:output]
    input_type = params[:input_type]

    @solved = problem.correct?(output, input_type)
    if @solved && !@score.solved_time(problem, input_type)
      score = @score.score +
        (input_type == 'small' ? problem.small_score : problem.large_score)
      @score.update_attributes(score: score)
    end
    Submit.create(solved: @solved, problem_id: problem.id, problem_type: input_type, score: @score)

    redirect_to action: 'index'
  end

  # GET /contests/1/problems/new
  # GET /contests/1/problems/new.json
  def new
    @problem = Problem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @problem }
    end
  end

  # POST /contests/1/problems
  # POST /contests/1/problems.json
  def create
    @problem = Problem.new(params[:problem])
    @problem.contest_id = params[:contest_id]

    respond_to do |format|
      if @problem.save
        format.html { redirect_to action: 'index' }
        format.json { render json: @problem, status: :created, location: @problem }
      else
        format.html { render action: 'new' }
        format.json { render json: @problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /contests/1/problems/1/edit
  def edit
    @problem = Problem.find(params[:id])
  end

  # PUT /contests/1/problems/1
  # PUT /contests/1/problems/1.json
  def update
    @problem = Problem.find(params[:id])

    respond_to do |format|
      if @problem.update_attributes(params[:problem])
        format.html { redirect_to action: 'index' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @problem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contests/1/problems/1
  # DELETE /contests/1/problems/1.json
  def destroy
    @problem = Problem.find(params[:id])
    @problem.destroy

    respond_to do |format|
      format.html { redirect_to action: 'index' }
      format.json { head :no_content }
    end
  end

  def download_small
    download(:small)
  end

  def download_large
    download(:large)
  end

  def download(type)
    p = Problem.find(params[:id])
    head = p.title.gsub(' ', '_') + '_'

    case type
    when :small
      send_data(p.small_input, filename: head + 'small.txt')
    when :large
      send_data(p.large_input, filename: head + 'large.txt')
    end
  end

end
