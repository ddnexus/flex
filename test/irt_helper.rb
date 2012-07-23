$:.unshift File.expand_path('../../lib', __FILE__)
require 'flex'

INDEX_NAME     = 'flex_test_index'
TMP_INDEX_NAME = 'flex_tmp_test_index'

INDEX_NAME_1   = 'flex_test_index_1'
INDEX_NAME_2   = 'flex_test_index_2'

Flex.create_index(:index => INDEX_NAME) unless Flex.exist?(:index => INDEX_NAME)
Flex.config.variables[:index] = INDEX_NAME
Flex.reload!
