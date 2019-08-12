# Prototype é um padrão de design criacional que permite a clonagem de objetos,
# mesmo complexos, sem acoplamento a suas classes específicas.

# A classe de exemplo que possui capacidade de clonagem. Vamos ver como os valores de campo
# com diferentes tipos serão clonados.
class Prototype
  attr_accessor :primitive, :component, :circular_reference

  def initialize
    @primitive = nil
    @component = nil
    @circular_reference = nil
  end

  # @return [Prototype]
  def clone
    @component = deep_copy(@component)

    # Clonar um objeto que tenha um objeto aninhado com backreference requer
    # tratamento especial. Após a conclusão da clonagem, o objeto aninhado
    # deve apontar para o objeto clonado, em vez do objeto original.
    @circular_reference = deep_copy(@circular_reference)
    @circular_reference.prototype = self
    deep_copy(self)
  end

  # deep_copy é o hack Marshalling usual para fazer uma cópia profunda. Mas é bastante
  # lento e ineficiente, portanto, em aplicações reais, use uma gem especial
  private def deep_copy(object)
    Marshal.load(Marshal.dump(object))
  end
end

class ComponentWithBackReference
  attr_accessor :prototype

  # @param [Prototype] prototype
  def initialize(prototype)
    @prototype = prototype
  end
end

# Código do cliente
p1 = Prototype.new
p1.primitive = 245
p1.component = Time.now
p1.circular_reference = ComponentWithBackReference.new(p1)

p2 = p1.clone

if p1.primitive == p2.primitive
  puts 'Valores de campo primitivos foram transferidos para um clone!'
else
  puts 'Valores de campo primitivos não foram copiados!'
end

if p1.component.equal?(p2.component)
  puts 'Componente simples não foi clonado.'
else
  puts 'Componente simples foi clonado.'
end

if p1.circular_reference.equal?(p2.circular_reference)
  puts 'O componente com referência de retorno não foi clonado.'
else
  puts 'Componente com referência de retorno foi clonado.'
end

 puts p1.circular_reference.prototype
 puts p2.circular_reference.prototype

if p1.circular_reference.prototype.equal?(p2.circular_reference.prototype)
  print 'O componente com referência de retorno está vinculado ao objeto original.'
else
  print 'O componente com referência de retorno está vinculado ao clone.'
end