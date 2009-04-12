if defined? Delayed
  Delayed::Job.const_set("MAX_ATTEMPTS", 10)
end