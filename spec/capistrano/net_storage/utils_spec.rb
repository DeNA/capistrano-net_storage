require 'spec_helper'

describe Capistrano::NetStorage::Utils do
  describe '#build_dest' do
    let(:src) { 'src/src_path.yml' }
    let(:dest_dir) { '/path/to/deploy_app' }
    let(:dest_path) { '/path/to/deploy_app/dest/dest_path.yml' }
    subject { self.extend(described_class).send(:build_dest, src, dest_dir: dest_dir, dest_path: dest_path) }

    context 'build from dest_path' do
      it { should eq('/path/to/deploy_app/dest/dest_path.yml') }
    end

    context 'build from src and dest_dir' do
      let(:dest_path) { nil }
      it { should eq('/path/to/deploy_app/src_path.yml') }
    end

    context 'build from only src' do
      let(:dest_dir) { nil }
      let(:dest_path) { nil }
      it { should eq(src) }
    end
  end
end
