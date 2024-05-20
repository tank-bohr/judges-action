# frozen_string_literal: true

# MIT License
#
# Copyright (c) 2024 Zerocracy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

fb.query("(and (eq what 'label-attached')
  (exists issue)
  (exists repository)
  (exists label))").each do |f1|
  $loog.debug("Label '#{f1.label}' was attached to issue ##{f1.issue}")
  once(fb).query("(and (eq what 'issue-closed')
    (exists who)
    (eq issue #{f1.issue})
    (eq repository #{f1.repository}))").each do |f2|
    fb.txn do |fbt|
      n = follow(fbt, f1, %w[repository issue])
      n.who = f2.who
      n.cause = f2.id
      # how long it was alive? let's add the data
      n.details =
        "In the repository ##{n.repository}, the issue ##{n.issue} " \
        "was closed by ##{n.who}, which is considered as a resolved bug " \
        "because the issue has the '#{f1.label}' label attached."
      n.what = 'bug-was-resolved'
    end
  end
end
