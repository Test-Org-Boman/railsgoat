class Admin::AnalyticsController < ApplicationController
  before_action :authenticated_user
  before_action :admin_user # Ensures only admin users access the route

  def index
    # Renders the configuration form for generating reports
  end

  def generate_pdf
    report_type   = params[:report_type]
    date_range    = params[:date_range]
    custom_footer = params[:footer_text] # User controlled string

    # Define paths for simulation
    html_source = Rails.root.join('tmp', "report_#{current_user.id}.html")
    pdf_output  = Rails.root.join('tmp', "report_#{current_user.id}.pdf")

    # Generate dummy content to feed into the PDF engine
    File.write(html_source, "<h1>#{report_type.capitalize} Report</h1><p>Range: #{date_range}</p>")

    # VULNERABILITY: Insecure string interpolation directly inside a shell execution context (`...`)
    # If custom_footer contains characters like `;`, `&&`, or `|`, arbitrary commands will execute.
    begin
      @output = `wkhtmltopdf --footer-center "#{custom_footer}" #{html_source} #{pdf_output} 2>&1`
      
      if File.exist?(pdf_output)
        send_file pdf_output, type: 'application/pdf', disposition: 'attachment'
      else
        render :index, alert: "PDF Generation failed. System Output: #{@output}"
      end
    ensure
      # Cleanup temporary artifacts
      File.delete(html_source) if File.exist?(html_source)
      File.delete(pdf_output) if File.exist?(pdf_output)
    end
  end

  private

  def admin_user
    redirect_to(root_path, alert: "Unauthorized access.") unless current_user.admin?
  end
end
