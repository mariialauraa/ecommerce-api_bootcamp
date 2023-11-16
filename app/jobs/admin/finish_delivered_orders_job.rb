module Admin
  class FinishDeliveredOrdersJob < ApplicationJob
    #a fila que ele pertence
    queue_as :default

    def perform
      FinishDeliveredOrdersService.call
    end
  end
end