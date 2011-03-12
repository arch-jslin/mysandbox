
package.path = [[c:\local_gitrepo\Penlight\lua\?.lua;]]..package.path
require 'luarocks.loader'
local MapUtils = require 'maputils'
local List = require 'pl.List'
local Test = require 'pl.test'
local tablex = require 'tablex2'
local Helper = require 'helpers'
local random, Stack = Helper.random, Helper.stack

-- ��ڦb�ˬd�W�A��{�ƫe�٭n�� intersects �U�h�|���|�y�� column �����z���A
-- �άO row �B�ŤF

-- �@function chain_limit
-- �@�@//��X��� 30011 �I�_���զX => �G�o���d��uA ��Q a b c �I�_�v�����įq�G
-- �@�@stack = {30011} //�q��Q���̩��U���զX���H�����@�ӥX�ӷ�
-- �@�@iterate on�uA ��Q a, b, c, ... �I�_�v�� a, b, c�FA �� stack[top]
-- �@�@�@push one of {a,b,c...} into stack
-- �@�@�@�̷����D��ܪk��{�L���A�ˬd�G
-- �@�@�@���঳�H�B��
-- �@�@�@�@(���Ψ�{�L���]���ˬd�H�ڥi�H keep track �ثe�L���C�� row ���d��A
-- �@�@�@�@ �æb�����D��ܪk�����q�N�簣�\�U�h�@�w�|�B�Ū�)
-- �@�@�@���঳ invoke (�b�٨S�W�⪺���p�U�|���o���D�ܡH)
-- �@�@�@iterate on colors
-- �@�@�@�@��J�o���I�A�õ��Ӭq�W�� (���ݦҼ{�o���I�C��)�A���ҥ��T�ʡG
-- �@�@�@�@�s�P�o���I�Ҽ{�A���঳ invoke
-- �@�@�@�@�����o���I�ô��կ�_�]������L���A����ѤU�F��
-- �@�@�@�@if ���S�ѤU then ++chain and break loop
-- �@�@�@end
-- �@�@�@if �Ҧ��C�ⳣ�չL�٬O���ѡApop stack
-- �@�@�@if time >= time_limit then return nil to indicate generation failed
-- �@�@�@if chain >= chain_limit then break loop
-- �@�@end
-- �@�@if chain < chain_limit return nil to indicate generation failed
-- �@�@�N���D��ܦ���{�Ʀ��L��
-- �@�@return �L��
-- �@end 

math.randomseed(os.time())

local PuzzleGen = {}

function PuzzleGen:init(w, h)
  self.row_ranges = {}
  self.heights = {}
  self.chains = Stack()
  self.colors = Stack()
  self.intersects_of, self.starter = MapUtils.create_intersect_sheet(w, h)
  for i = 1, h do
    self.row_ranges[i] = {s = 0, e = 0}
  end
  for i = 1, w do 
    self.heights[i] = 0
  end
  for k,v in pairs(self.intersects_of) do
    tablex.shuffle(v) -- randomize
  end
  self.inited = true
end

function PuzzleGen:update_ranges_heights()
  local lenH, lenV, _, x, y = MapUtils.analyze( self.chains:top() )
  if lenH > 0 then
    for i = x, x + lenH - 1 do
      -- starts from here
    end
  elseif lenV > 0 then
  end
end

function PuzzleGen:generate(chain_limit, w, h)
  w, h = w or 6, h or 10
  if not self.inited then self:init(w, h) end
 
  self.chains:push(self.starter[random(#self.starter)+1])
  self.colors:push(1)
  
  local intersects = self.intersects_of[ self.chains:top() ]
  local i = 1
  while intersects[i] do
    break
    --self.chains:push(intersects[i]) 
  end
end

PuzzleGen:generate(7, 6, 10)

