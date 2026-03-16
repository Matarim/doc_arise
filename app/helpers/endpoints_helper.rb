# frozen_string_literal: true

module EndpointsHelper
  def method_badge_class(method)
    case method.to_s.downcase
    when 'get'    then 'bg-emerald-900 text-emerald-300'
    when 'post'   then 'bg-blue-900 text-blue-300'
    when 'put'    then 'bg-amber-900 text-amber-300'
    when 'patch'  then 'bg-purple-900 text-purple-300'
    when 'delete' then 'bg-red-900 text-red-300'
    else 'bg-zinc-700 text-zinc-300'
    end
  end
end
