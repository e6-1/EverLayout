//  EverLayout
//
//  Copyright (c) 2017 Dale Webster
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public class ELConstraint: ELRawData
{
    public var constraintParser : LayoutConstraintParser!
    
    public var leftSideAttributes : [NSLayoutAttribute?]? {
        return self.constraintParser.leftSideAttributes(source: self.rawData)
    }
    public var rightSideAttribute : NSLayoutAttribute? {
        return self.constraintParser.rightSideAttribute(source: self.rawData)
    }
    public var constant : ELConstraintConstant {
        return self.constraintParser.constant(source: self.rawData) ?? ELConstraintConstant(value: 0, sign: .positive)
    }
    public var multiplier : ELConstraintMultiplier {
        return self.constraintParser.multiplier(source: self.rawData) ?? ELConstraintMultiplier(value: 1, sign: .multiply)
    }
    public var priority : CGFloat? {
        return self.constraintParser.priority(source: self.rawData)
    }
    public var relation : NSLayoutRelation {
        return self.constraintParser.relation(source: self.rawData) ?? .equal
    }
    public var comparableViewReference : String? {
        return self.constraintParser.comparableViewReference(source: self.rawData)
    }
    public var identifier : String? {
        return self.constraintParser.identifier(source: self.rawData)
    }
    
    public init (rawData : Any , parser : LayoutConstraintParser)
    {
        super.init(rawData: rawData)
        
        self.constraintParser = parser
    }
    
    public func establisConstaints (onView view : ELView , withViewIndex viewIndex : ViewIndex , viewEnvironment : NSObject? = nil)
    {
        guard let target = view.target else { return }
        
        for attr in self.leftSideAttributes ?? []
        {
            guard let attr = attr else { continue }
            
            // Properties of the constraints can be changed or inferred to make writing them easier. For this we
            // will use a EverLayoutConstraintContext
            let context = ELConstraintContext(
                _target: target,
                _leftSideAttribute: attr,
                _relation: self.relation,
                _comparableView: (self.comparableViewReference == "super") ? target.superview : viewIndex.view(forKey: self.comparableViewReference ?? "") ?? viewEnvironment?.property(forKey: self.comparableViewReference ?? "") as? UIView,
                _rightSideAttribute: self.rightSideAttribute,
                _constant: self.constant,
                _multiplier: self.multiplier)
            
            // Create the constraint from the context
            let constraint : NSLayoutConstraint = NSLayoutConstraint(item: context.target, attribute: context.leftSideAttribute, relatedBy: context.relation, toItem: context.comparableView, attribute: context.rightSideAttribute ?? context.leftSideAttribute, multiplier: context.multiplier.value, constant: context.constant.value)
            
            // Constraint priority
            if let priority = self.priority
            {
                constraint.priority = UILayoutPriority(priority)
            }
            
            // Add an identifier to the constraint
            constraint.identifier = self.identifier
            
            // Add the constraint to either the target's superview or just the target itself
            if target.superview != nil
            {
                target.superview?.addConstraint(constraint)
            }
            else
            {
                target.addConstraint(constraint)
            }
        }
    }
}






