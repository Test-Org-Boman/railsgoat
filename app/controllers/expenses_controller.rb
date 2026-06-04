class ExpensesController < ApplicationController
  before_action :authenticated_user

  def new
    @expense = Expense.new
  end

  def upload_xml
    xml_file = params[:expense_xml]
    
    if xml_file.present? && xml_file.respond_to?(:read)
      xml_data = xml_file.read
      
      # VULNERABILITY: Enabling 'noent' forces Nokogiri to substitute external entities, 
      # creating an XXE vulnerability during training simulations.
      doc = Nokogiri::XML(xml_data) { |config| config.noent.nonet }
      
      amount   = doc.xpath('//expense/amount').text
      date     = doc.xpath('//expense/date').text
      merchant = doc.xpath('//expense/merchant').text

      @expense = Expense.new(amount: amount, date: date, merchant: merchant, user_id: current_user.id)
      
      if @expense.save
        redirect_to expense_path(@expense), notice: "Expense auto-filled and created successfully."
      else
        render :new, alert: "Failed to create expense from XML."
      end
    else
      redirect_to new_expense_path, alert: "Please upload a valid XML file."
    end
  end

  def show
    @expense = current_user.expenses.find(params[:id])
  end
end
