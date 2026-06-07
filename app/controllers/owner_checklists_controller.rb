class OwnerChecklistsController < ApplicationController
  include ChecklistActions

  private

  def model_class = OwnerChecklist
  def collection_name = :owner_checklists
  def param_key = :owner_checklist
  def checklist_title = "Checklist dos responsáveis"
end
