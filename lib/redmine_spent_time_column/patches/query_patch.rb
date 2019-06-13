module RedmineSpentTimeColumn
  module Patches
    module QueryPatch
      
      def available_columns_with_spent_hours
        available_columns_without_spent_hours.tap do |columns|
          if (project and User.current.allowed_to?(:view_time_entries, project)) or User.current.admin?
            if Setting.plugin_redmine_spent_time_column['enable_spent_hours_column'] == '1'
              columns << QueryColumn.new(:spent_hours, 
                :caption => :label_spent_time, 
                :sortable => "(select sum(hours) from #{TimeEntry.table_name} where #{TimeEntry.table_name}.issue_id = #{Issue.table_name}.id)"
              ) unless columns.detect{ |c| c.name == :spent_hours }
            end

            if Setting.plugin_redmine_spent_time_column['enable_calculated_spent_hours_column'] == '1'
              columns << QueryColumn.new(:calculated_spent_hours,
                :caption => :label_calculated_spent_hours,
                :sortable => "(IF(#{Issue.table_name}.estimated_hours IS NULL,0,#{Issue.table_name}.estimated_hours) * #{Issue.table_name}.done_ratio / 100)"
              ) unless columns.detect{ |c| c.name == :calculated_spent_hours }
            end

            if Setting.plugin_redmine_spent_time_column['enable_divergent_hours_column'] == '1'
              columns << QueryColumn.new(:divergent_hours,
                :caption => :label_divergent_hours,
                :sortable => "((select sum(hours) from #{TimeEntry.table_name} where #{TimeEntry.table_name}.issue_id = #{Issue.table_name}.id) - (IF(#{Issue.table_name}.estimated_hours IS NULL,0,#{Issue.table_name}.estimated_hours) * #{Issue.table_name}.done_ratio / 100))"
              ) unless columns.detect{ |c| c.name == :divergent_hours }
            end

            if Setting.plugin_redmine_spent_time_column['enable_calculated_remaining_hours_column'] == '1'
              columns << QueryColumn.new(:calculated_remaining_hours,
                :caption => :label_calculated_remaining_hours,
                :sortable => "(IF(#{Issue.table_name}.estimated_hours IS NULL,0,#{Issue.table_name}.estimated_hours) - (IF(#{Issue.table_name}.estimated_hours IS NULL,0,#{Issue.table_name}.estimated_hours) * #{Issue.table_name}.done_ratio / 100))"
              ) unless columns.detect{ |c| c.name == :calculated_remaining_hours }
            end
          end
        end
      end

      def self.included(klass)
        klass.send :alias_method_chain, :available_columns, :spent_hours
      end
      
    end
  end
end
