require 'spec_helper'

describe ArrayWithProgress do
  before do
    String.disable_colorization = true
  end

  it 'should return correct terminal width' do
    terminal_width = `tput cols`.to_i

    expect(ArrayProgressConfiguration.terminal_width).to eq terminal_width
    expect(ArrayProgressConfiguration.item_width).to eq (terminal_width - 22)
  end
end