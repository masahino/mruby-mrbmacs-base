module Mrbmacs
  # Semantic syntax roles and their fallback relationships.
  module StyleRole
    PARENTS = {
      function_call: :function_name,
      variable_use: :variable_name,
      property_name: :variable_name,
      property_use: :property_name,
      preprocessor: :builtin,
      documentation: :string,
      documentation_markup: :constant,
      escape: :regexp_grouping_backslash,
      number: :constant,
      operator: :default,
      punctuation: :default,
      bracket: :punctuation,
      delimiter: :punctuation,
      regexp: :regexp_grouping_construct,
      error: :warning,
      markup_heading: :function_name,
      markup_emphasis: :documentation_markup,
      markup_link: :function_name,
      markup_code: :string,
      diff_added: :string,
      diff_deleted: :warning,
      diff_changed: :constant
    }.freeze

    LEGACY_NAMES = {
      default: :color_default,
      builtin: :color_builtin,
      comment: :color_comment,
      constant: :color_constant,
      function_name: :color_function_name,
      keyword: :color_keyword,
      string: :color_string,
      type: :color_type,
      variable_name: :color_variable_name,
      warning: :color_warning,
      preprocessor: :color_preprocessor,
      regexp: :color_regexp,
      documentation: :color_doc,
      documentation_string: :color_doc_string,
      color_constant: :color_color_constant,
      comment_delimiter: :color_comment_delimiter,
      negation_char: :color_negation_char,
      other_type: :color_other_type,
      regexp_grouping_construct: :color_regexp_grouping_construct,
      special_keyword: :color_special_keyword,
      exit: :color_exit,
      other_emphasized: :color_other_emphasized,
      regexp_grouping_backslash: :color_regexp_grouping_backslash
    }.freeze

    class << self
      def parent(role)
        PARENTS[normalize(role)]
      end

      def legacy_name(role)
        LEGACY_NAMES[normalize(role)]
      end

      def normalize(role)
        return role unless role.is_a?(Symbol)

        name = role.to_s
        return role unless name.start_with?('color_')

        legacy = nil
        LEGACY_NAMES.each do |semantic_name, legacy_name|
          if legacy_name == role
            legacy = semantic_name
            break
          end
        end
        legacy || name.sub(/^color_/, '').to_sym
      end

      def ancestors(role)
        roles = []
        current = normalize(role)
        while current && !roles.include?(current)
          roles << current
          current = parent(current)
        end
        roles << :default unless roles.include?(:default)
        roles
      end
    end
  end
end
