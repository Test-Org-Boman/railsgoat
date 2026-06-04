class TicketsController < ApplicationController
  before_action :authenticated_user

  def index
    if current_user.admin?
      @tickets = Ticket.all
    else
      @tickets = current_user.tickets
    end
  end

  def show
    # VULNERABILITY: Direct reference lookup using parameters. 
    # It fails to verify that @ticket.user_id == current_user.id for non-admin users.
    @ticket = Ticket.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tickets_path, alert: "Ticket not found."
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = current_user.tickets.build(ticket_params)
    if @ticket.save
      redirect_to ticket_path(@ticket), notice: "Ticket submitted successfully."
    else
      render :new
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :description, :category)
  end
end
