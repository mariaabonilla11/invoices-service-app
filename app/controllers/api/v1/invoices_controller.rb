
require_relative '../../../use_cases/invoices/create_invoice'
require_relative '../../../use_cases/invoices/find_invoice'
require_relative '../../../use_cases/invoices/filter_invoices'
require_relative '../../../domain/validators/invoice_validator'
require_dependency Rails.root.join('app/infrastructure/repositories/oracle_invoice_repository').to_s
require_dependency Rails.root.join('app/infrastructure/http/client_service').to_s
class Api::V1::InvoicesController < ApplicationController
  def create
    attrs = invoice_params.to_h.symbolize_keys
    invoice = Domain::Entities::Invoice.new(**attrs)
    validator = Domain::Validators::InvoiceValidator.new(invoice)
    unless validator.valid?
      render json: { message: 'Errores de validación', errors: validator.errors }, status: :unprocessable_entity and return
    end

    client_service = Infrastructure::Http::ClientService.new
    client = client_service.find_client(invoice.client_id)

    unless client
      render json: { message: 'Cliente no encontrado' }, status: :not_found and return
    end

    result = ::UseCases::Invoices::CreateInvoice.new.execute(invoice)
    if result.is_a?(Hash) && result[:errors]
      render json: { message: 'Errores de validación', errors: result[:errors] }, status: :unprocessable_entity
    else
      render json: { message: 'Factura creada exitosamente', invoice: result }, status: :created
    end
  end

  def show
    invoice_id = params[:id]
    invoice_repository = Infrastructure::Repositories::OracleInvoiceRepository.new
    result = ::UseCases::Invoices::FindInvoice.new(invoice_repository: invoice_repository).execute(invoice_id)

    if result[:success]
      render json: { message: "Factura encontrada exitosamente", invoice: result}, status: :ok
    else
      render json: { message: "Factura no encontrada", errors: result[:errors] }, status: :not_found
    end
  end

  def index
    invoice_repository = Infrastructure::Repositories::OracleInvoiceRepository.new
    params_permit = params.permit(:start_date, :end_date)
    filter_params = {
      start_date: params_permit[:start_date],
      end_date: params_permit[:end_date]
    }
    result = ::UseCases::Invoices::FilterInvoices.new(repository: invoice_repository).execute(filter_params)

    if result[:success]
      render json: { message: "Facturas filtradas exitosamente", invoices: result[:data] }, status: :ok
    else
      render json: { message: "Error al filtrar facturas", errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:client_id, :amount, :status, :due_date)
  end
end