class ManagerChecklistsController < ApplicationController
  include ChecklistActions

  private

  def model_class = ManagerChecklist
  def collection_name = :manager_checklists
  def param_key = :manager_checklist
  def checklist_title = "Checklist interno"
end
