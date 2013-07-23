class Employee

  attr_accessor :name, :title, :salary, :boss

  def initialize(name, title, salary, boss)
    @name   = name
    @title  = title
    @salary = salary
    @boss   = boss
  end

  def bonus(multiplier)
    self.salary * multiplier
  end

end

class Manager < Employee

  attr_accessor :employees

  def initialize(name, title, salary, boss)
    super(name, title, salary, boss)
    @employees = []
  end

  def add_employee(employee_object)
    @employees << employee_object
    employee_object.boss = self
  end

  def bonus(multiplier)
    money = 0

    @employees.each do |peon|
      if peon.instance_of?(Employee)
        money += peon.salary
      else
        money += peon.salary
        # Recursive Step
        money += peon.bonus(1)
      end
    end

    money * multiplier
  end

end

ned = Manager.new("ned", "honcho", 2, nil)
dylan = Manager.new("dylan", "dude", 1.5, ned)

a = Employee.new("a", "a", 1, ned)
b = Employee.new("b", "b", 1, ned)
c = Employee.new("d", "d", 1, dylan)
d = Employee.new("d", "d", 1, dylan)

ned.add_employee(a)
ned.add_employee(b)
ned.add_employee(dylan)

dylan.add_employee(c)
dylan.add_employee(d)

p ned.bonus(2)
