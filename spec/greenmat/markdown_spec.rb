require 'greenmat'

module Greenmat
  RSpec.describe Markdown do
    subject(:markdown) { Markdown.new(renderer, options) }
    let(:renderer) { Render::HTML.new }
    let(:options) { {} }
    let(:rendered_html) { markdown.render(text) }

    context 'with sub-lists' do
      context 'with 4 space based indentations' do
        let(:text) { <<-END.gsub(/^\s+\|/, '') }
          |- foo
          |    - bar
          |        - baz
        END

        it 'properly handles the list levels' do
          expect(rendered_html).to eq(<<-END.gsub(/^\s+\|/, ''))
            |<ul>
            |<li>foo
            |
            |<ul>
            |<li>bar
            |
            |<ul>
            |<li>baz</li>
            |</ul></li>
            |</ul></li>
            |</ul>
          END
        end
      end

      context 'with 2 space based indentations' do
        let(:text) { <<-END.gsub(/^\s+\|/, '') }
          |- foo
          |  - bar
          |    - baz
        END

        it 'properly handles the list levels' do
          expect(rendered_html).to eq(<<-END.gsub(/^\s+\|/, ''))
            |<ul>
            |<li>foo
            |
            |<ul>
            |<li>bar
            |
            |<ul>
            |<li>baz</li>
            |</ul></li>
            |</ul></li>
            |</ul>
          END
        end
      end
    end

    context 'with no_mention_emphasis option' do
      let(:options) { { no_mention_emphasis: true } }

      [
        ['@_username_',         false],
        ['@__username__',       false],
        ['@___username___',     false],
        ['@user__name__',       false],
        ['@some__user__name__', false],
        [' @_username_',        false],
        ['あ@_username_',       false],
        ['A@_username_',        true],
        ['@*username*',         true],
        ['_foo_',               true],
        ['_',                   false],
        ['_foo @username_',     false],
        ['__foo @username__',   false],
        ['___foo @username___', false]
      ].each do |text, emphasize|
        context "with text #{text.inspect}" do
          let(:text) { text }

          if emphasize
            it 'emphasizes the text' do
              expect(rendered_html).to include('<em>').or include('<strong>')
            end
          else
            it 'does not emphasize the text' do
              expect(rendered_html.chomp).to eq("<p>#{text.strip}</p>")
            end
          end
        end
      end
    end

    context 'without no_mention_emphasis option' do
      let(:options) { {} }

      context 'with text "@_username_"' do
        let(:text) { '@_username_' }

        it 'emphasizes the text' do
          expect(rendered_html).to include('<em>')
        end
      end

      context 'with text "_foo @username_"' do
        let(:text) { '_foo @username_' }

        it 'emphasizes the text' do
          expect(rendered_html).to include('<em>')
        end
      end
    end
  end
end
